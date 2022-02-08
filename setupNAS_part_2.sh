#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i.bak s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo "# THis is now the x64 version for Raspberry Pi OS x64 - and ONLY the x64 version"
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
set -x
cd ~/Desktop
set +x
while true; do
	read -p "Have you completed the pre-Install instructions per README.md AND run 'setupNAS_part_1.sh' ? [y/n]? " yn
	case $yn in
		[Yy]* ) OK=y; break;;
		[Nn]* ) OK=n; break;;
		* ) echo "Please answer y or n only.";;
	esac
done
if [ "${OK}" = "n" ]; then
	echo ""
	echo ""
	echo "You MUST first complete the pre-Install instructions per README.md AND run 'setupNAS_part_1.sh' "
	echo ""
	echo ""
	exit
fi
echo ""
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
while true; do
	read -p "Have you plugged in the USB3 external disk(s) into the correct USB3 slots yet ? [y/n]? " yn
	case $yn in
		[Yy]* ) OK=y; break;;
		[Nn]* ) OK=n; break;;
		* ) echo "Please answer y or n only.";;
	esac
done
if [ "${OK}" = "n" ]; then
	echo ""
	echo ""
	echo "You MUST plug in the USB3 external disk(s) into the correct USB3 slots first"
	echo ""
	echo ""
	exit
fi
echo ""
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Ask for and setup default settings and try to remember them."
echo ""
sdname=./setupNAS_ask_defaults.sh
echo . "${sdname}"
# Yes there's a ". " at the start of the line '. "${sdname}"'
set -x
. "${sdname}"
set +x
echo ""
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Install 'hd-idle' so that external USB3 disks spin down when idle and not wear out quickly."
echo ""
echo "# Some WD external USB3 disks won't spin down on idle and HDPARM and SDPARM don't work on them."
echo "# ... 'adelolmo' version of hd-idle appears to work, so let's use that."
echo ""
# https://www.htpcguides.com/spin-down-and-manage-hard-drive-power-on-raspberry-pi/
echo ""
echo "# FIRST USB3 DISK"
echo "#     USB3_DISK_NAME_1=${USB3_DISK_NAME_1}"
echo "#   USB3_DEVICE_NAME_1=${USB3_DEVICE_NAME_1}"
echo "#   USB3_DEVICE_UUID_1=${USB3_DEVICE_UUID_1}"
if [ "${SecondDisk}" = "y" ]; then
	echo "# SECOND USB3 DISK"
	echo "#    USB3_DISK_NAME_2=${USB3_DISK_NAME_2}"
	echo "#  USB3_DEVICE_NAME_2=${USB3_DEVICE_NAME_2}"
	echo "#  USB3_DEVICE_UUID_2=${USB3_DEVICE_UUID_2}"
fi
echo "# Attributes of FIRST USB3 DISK"
set -x
sudo blkid
sudo df
sudo lsblk
sudo blkid -U ${USB3_DEVICE_UUID_1}
sudo df -l /dev/${USB3_DISK_NAME_1}
sudo lsblk /dev/${USB3_DISK_NAME_1}
set +x
if [ "${SecondDisk}" = "y" ]; then
	echo "# Attributes of SECOND USB3 DISK"
	set -x
	sudo blkid -U ${USB3_DEVICE_UUID_2}
	sudo df -l /dev/${USB3_DISK_NAME_2}
	sudo lsblk /dev/${USB3_DISK_NAME_2}
	set +x
fi
echo ""
echo "# List and Remove any prior hd-idle package"
echo ""
set -x
sudo systemctl disable hd-idle
sleep 1s
sudo dpkg -l hd-idle
sudo dpkg -P hd-idle 
# dpkg -P is the one that works for us, also use 'apt purge' in case an old one was instaleld via apt
sudo apt purge -y hd-idle
set +x
#
echo ""
echo "# Install the more up-to-date release of 'adelolmo' version of hd-idle"
echo ""
# https://github.com/adelolmo/hd-idle
set -x
cd ~/Desktop
rm -fvr ./hd-idle
mkdir -pv hd-idle
cd hd-idle
hdidle_ver=1.16
hdidle_deb=hd-idle_${hdidle_ver}_arm64.deb
hdidle_url=https://github.com/adelolmo/hd-idle/releases/download/v${hdidle_ver}/${hdidle_deb}
sudo rm -vf "./${hdidle_deb}"
wget ${hdidle_url}
sudo dpkg -i "./${hdidle_deb}"
sudo dpkg -l hd-idle
cd ~/Desktop
set +x
echo ""
# option -d = debug
##Double check hd-idle works with your hard drive
##sudo hd-idle -t ${server_USB3_DEVICE_NAME} -d
#   #Command line options:
#   #-a name Set device name of disks for subsequent idle-time parameters -i. This parameter is optional in the sense that there's a default entry for all disks which are not named otherwise by using this parameter. This can also be a symlink (e.g. /dev/disk/by-uuid/...)
#   #-i idle_time Idle time in seconds for the currently named disk(s) (-a name) or for all disks.
#   #-c command_type Api call to stop the device. Possible values are scsi (default value) and ata.
#   #-s symlink_policy Set the policy to resolve symlinks for devices. If set to 0, symlinks are resolve only on start. If set to 1, symlinks are also resolved on runtime until success. By default symlinks are only resolve on start. If the symlink doesn't resolve to a device, the default configuration will be applied.
#   #-l logfile Name of logfile (written only after a disk has spun up or spun down). Please note that this option might cause the disk which holds the logfile to spin up just because another disk had some activity. On single-disk systems, this option should not cause any additional spinups. On systems with more than one disk, the disk where the log is written will be spun up. On raspberry based systems the log should be written to the SD card.
#   #-t disk Spin-down the specified disk immediately and exit.
#   #-d Debug mode. It will print debugging info to stdout/stderr (/var/log/syslog if started with systemctl)
#   #-h Print usage information.
## observe output
##Use Ctrl+C to stop hd-idle in the terminal
echo ""
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Modify the hd-idle configuration file to enable the service to automatically start and spin down drives"
echo ""
set -x
sudo systemctl stop hd-idle
sleep 2s
# default timeout 300s = 5 mins
# sda     timeout 900s = 15 mins
the_default_timeout=300
the_sda_timeout=900
set +x
echo ""
idle_opts="HD_IDLE_OPTS=\"-i ${the_default_timeout} "
idle_opts+=" -a ${USB3_DISK_NAME_1} -i ${the_sda_timeout} "
if [ "${SecondDisk}" = "y" ]; then
	idle_opts+=" -a ${USB3_DISK_NAME_2} -i ${the_sda_timeout} "
fi
idle_opts+=" -l /var/log/hd-idle.log\n\""
echo "Setting idle_opts=${idle_opts}"
echo ""
set -x
sudo cp -fv "/etc/default/hd-idle" "/etc/default/hd-idle.old"
sudo sed -i "s;START_HD_IDLE=;#START_HD_IDLE=;g" "/etc/default/hd-idle"
sudo sed -i "s;HD_IDLE_OPTS=;#HD_IDLE_OPTS=;g" "/etc/default/hd-idle"
sudo sed -i "1 i START_HD_IDLE=true" "/etc/default/hd-idle" # insert at line 1
sudo sed -i "$ a ${idle_opts}" "/etc/default/hd-idle" # insert as last line
sudo cat "/etc/default/hd-idle"
set +x
#sudo diff -U 10 "/etc/default/hd-idle.old" "/etc/default/hd-idle"
# start and enable start at system boot, per instructions https://github.com/adelolmo/hd-idle/
sudo systemctl stop hd-idle
sudo systemctl enable hd-idle
sudo systemctl restart hd-idle
sleep 2s
set +x
echo ""
sleep 5s
sudo cat /var/log/hd-idle.log
set +x
echo ""
echo "# Finished installation of hd-idle so that external USB3 disks spin down when idle and not wear out quickly."
echo ""








echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Install NFS and create the NFS shares"
echo ""
# https://magpi.raspberrypi.org/articles/raspberry-pi-samba-file-server
# https://pimylifeup.com/raspberry-pi-samba/
#
# define share root name and location(s)
#
nfs_export_top="/NFS-shares"
nfs_export_full_1="${nfs_export_top}/${virtual_folder_name_1}"
if [ "${SecondDisk}" = "y" ]; then
	nfs_export_full_2="${nfs_export_top}/${virtual_folder_name_2}"
else
	nfs_export_full_2=""
fi
echo ""
#
#echo "### NO NO NO Un-Install any previous NFS install ... 
echo "# Just STOP the NFS service instead of uninstalling it."
echo ""
set -x
cd ~/Desktop
## do not unmount them
##sudo umount -f "${nfs_export_full_1}"
##sudo umount -f "${nfs_export_full_2}"
echo "The first time around, this 'stop nfs-kernel-server' may fail since NFS is not yet installed. That's OK."
sudo systemctl stop nfs-kernel-server
sleep 3s
## apt purge seems to cause it to fail on the subsequent re-install, so let's NOT apt purge.
##sudo apt purge -y nfs-common
##sudo apt purge -y nfs-kernel-server 
##sudo apt autoremove -y
set +x
echo ""
echo "# Install NFS then stop it again immediately."
echo ""
set -x
sudo apt install -y nfs-kernel-server 
sudo apt install -y nfs-common
sudo systemctl stop nfs-kernel-server
sleep 2s
sudo systemctl enable nfs-kernel-server
sleep 2s
echo ""
## Do not do any of these commented out lines
##sudo rm -fv "/etc/exports"
##sudo rm -fv "/etc/default/nfs-kernel-server"
##sudo rm -fv "/etc/idmapd.conf"
## do NOT NOT NOT use rm on the next 2 items, as it may accidentally wipe all of our media files !!!
##sudo rm -fvR "${nfs_export_full_1}"
##sudo rm -fvR "${nfs_export_top}"
echo ""
echo "# Check that uid=1000 and gid=1000 match the user/group pi "
echo ""
sudo id -u pi
sudo id -g pi
pi_uid="$(id -r -u pi)"
pi_gid="$(id -r -g pi)"
echo "uid=$(id -r -u pi) gid=$(id -r -g pi)" 
echo ""
echo "# Create the NFS mount folders for the disks on our OS root drive, and set permissive protections on them"
echo ""
set -x
cd ~/Desktop
sudo mkdir -pv "${nfs_export_top}"
sudo chmod -c a=rwx -R "${nfs_export_top}"
sudo mkdir -pv "${nfs_export_full_1}"
sudo chmod -c a=rwx -R "${nfs_export_full_1}"
set +x
if [ "${SecondDisk}" = "y" ]; then
	set -x
	sudo mkdir -pv "${nfs_export_full_2}"
	sudo chmod -c a=rwx -R "${nfs_export_full_2}"
	set +x
fi
#
# Syntax for mount: sudo mount -v --bind  "existing-folder-tree" "new-mount-point-folder"
#
# do NOT umount nfs_export_full as it dismounts the underpinning volume and causes things to crash 
#sudo umount -f "${nfs_export_full_1}" 
#sudo mount -v -a # a : Mounts all devices described at /etc/fstab.
echo ""
echo "# Re-start the NFS server"
echo ""
set -x
sudo systemctl stop nfs-kernel-server
sleep 3s
sudo systemctl restart nfs-kernel-server
sleep 3s
set +x
echo ""
echo "# Manually mount the NFS shares (they are not yet in fstab)"
echo ""
set -x
sudo df -h
sudo mount -l
sudo mount -v --bind "${root_folder_1}" "${nfs_export_full_1}" --options defaults,nofail,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=$(id -r -u pi),gid=$(id -r -g pi),noatime,nodiratime,x-systemd.device-timeout=120
sudo ls -al "${root_folder_1}" 
sudo ls -al "${nfs_export_full_1}" 
set +x
if [ "${SecondDisk}" = "y" ]; then
	set -x
	sudo mount -v --bind "${root_folder_2}" "${nfs_export_full_2}" --options defaults,nofail,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=$(id -r -u pi),gid=$(id -r -g pi),noatime,nodiratime,x-systemd.device-timeout=120
	sudo ls -al "${root_folder_2}" 
	sudo ls -al "${nfs_export_full_2}" 
	set +x
fi
echo ""
set -x
sudo df -h
sudo blkid
sudo df -h
sudo mount -l
set +x
echo ""
echo "# Now add new NFS lines to file '/etc/fstab' so that the NFS shares are mounted at boot the same way every time"
echo ""
# Comment out any prior NFS mount points in '/etc/fstab'
set -x
sudo rm -fv "/etc/fstab.pre-nfs.old"
sudo cp -fv "/etc/fstab" "/etc/fstab.pre-nfs.old"
sudo sed -iBAK "s;${root_folder_1} ${nfs_export_full_1};#${root_folder_1} ${nfs_export_full_1};g" "/etc/fstab"
sudo sed -iBAK "s;${root_folder_2} ${nfs_export_full_2};#${root_folder_2} ${nfs_export_full_2};g" "/etc/fstab" # do the SECOND just in case there was one previously
sudo sed -iBAK   "s;##;#;g" "/etc/fstab"
# add the new shares
sudo sed -iBAK "$ a ${root_folder_1} ${nfs_export_full_1} none bind,defaults,nofail,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=$(id -r -u pi),gid=$(id -r -g pi),noatime,nodiratime,x-systemd.device-timeout=120 0 0" "/etc/fstab"
set +x
if [ "${SecondDisk}" = "y" ]; then
	set -x
	sudo sed -iBAK "$ a ${server_root_folder2} ${nfs_export_full_2} none bind,defaults,nofail,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=$(id -r -u pi),gid=$(id -r -g pi),noatime,nodiratime,x-systemd.device-timeout=120 0 0" "/etc/fstab"
	set +x
fi
echo ""
set -x
sudo cat "/etc/fstab"
sudo diff -U 10 "/etc/fstab.pre-nfs.old" "/etc/fstab" 
set +x
echo ""
echo "# Now add lines to file '/etc/exports' which definine the new NFS shares"
echo ""
# note: id 1000 is user pi $(id -r -u pi) and group pi $(id -r -g pi)
set -x
sudo cp -fv "/etc/exports" "/etc/exports.old"
#... START of comment out prior NFS export entries, including second ones in case they exist previously
sudo sed -i "s;${nfs_export_top} ${server_ip}/24;#${nfs_export_top} ${server_ip}/24;g" "/etc/exports"
sudo sed -i "s;${nfs_export_top} 127.0.0.1;#${nfs_export_top}127.0.0.1;g" "/etc/exports"
sudo sed -i "s;${nfs_export_full_1} ${server_ip}/24;#${nfs_export_full_1} ${server_ip}/24;g" "/etc/exports"
sudo sed -i "s;${nfs_export_full_1} 127.0.0.1;#${nfs_export_full_1} 127.0.0.1;g" "/etc/exports"
sudo sed -i "s;${nfs_export_full_2} ${server_ip}/24;#${nfs_export_full_1} ${server_ip}/24;g" "/etc/exports"
sudo sed -i "s;${nfs_export_full_2} 127.0.0.1;#${nfs_export_full_1} 127.0.0.1;g" "/etc/exports"
set +x
#... END of comment out prior NFS export entries
#... START of add entries for the LAN IP range
#sudo sed -i "$ a ${nfs_export_top} ${server_ip}/24(rw,insecure,sync,no_subtree_check,all_squash,crossmnt,fsid=0,root_squash,anonuid=$(id -r -u pi),anongid=$(id -r -g pi))" "/etc/exports"
set -x
sudo sed -i "$ a ${nfs_export_full_1} ${server_ip}/24(rw,insecure,sync,no_subtree_check,all_squash,crossmnt,anonuid=$(id -r -u pi),anongid=$(id -r -g pi))" "/etc/exports"
set +x
if [ "${SecondDisk}" = "y" ]; then
	set -x
	sudo sed -i "$ a ${nfs_export_full_2} ${server_ip}/24(rw,insecure,sync,no_subtree_check,all_squash,crossmnt,anonuid=$(id -r -u pi),anongid=$(id -r -g pi))" "/etc/exports"
	set +x
fi
#... END OF add entries for the LAN IP range
#... START of add entries for localhost 127.0.0.1
#sudo sed -i "$ a ${nfs_export_top} 127.0.0.1(rw,insecure,sync,no_subtree_check,all_squash,crossmnt,fsid=0,root_squash,anonuid=$(id -r -u pi),anongid=$(id -r -g pi))" "/etc/exports"
set -x
sudo sed -i "$ a ${nfs_export_full_1} 127.0.0.1(rw,insecure,sync,no_subtree_check,all_squash,crossmnt,anonuid=$(id -r -u pi),anongid=$(id -r -g pi))" "/etc/exports"
set +x
if [ "${SecondDisk}" = "y" ]; then
	set -x
	sudo sed -i "$ a ${nfs_export_full_2} 127.0.0.1(rw,insecure,sync,no_subtree_check,all_squash,crossmnt,anonuid=$(id -r -u pi),anongid=$(id -r -g pi))" "/etc/exports"
	set +x
fi
#... END of add entries for localhost 127.0.0.1
set -x
sudo cat "/etc/exports"
sudo diff -U 10 "/etc/exports.old" "/etc/exports"
set +x
echo ""
echo "# Now modify file '/etc/default/nfs-kernel-server' to add parameter NEED_SVCGSSD"
echo ""
#then check
# The only important option in /etc/default/nfs-kernel-server for now is NEED_SVCGSSD. 
# It is set to "no" by default, which is fine, because we are not activating NFSv4 security this time.
echo ""
set -x
sudo sed -i 's;NEED_SVCGSSD="";NEED_SVCGSSD="no";g' "/etc/default/nfs-kernel-server"
set +x
echo ""
set -x
sudo cat "/etc/default/nfs-kernel-server"
set +x
echo ""
#
# In order for the ID names to be automatically mapped, the file /etc/idmapd.conf 
# must exist on both the client and the server with the same contents and with the correct domain names. 
# Furthermore, this file should have the following lines in the Mapping section:
#[Mapping]
#Nobody-User = nobody
#Nobody-Group = nogroup
echo ""
echo "# Now check file '/etc/idmapd.conf' has the following 3 lines (it should) "
echo "[Mapping]"
echo "Nobody-User = nobody"
echo "Nobody-Group = nogroup"
echo ""
set -x
sudo cat "/etc/idmapd.conf"
set +x
echo ""
echo "# Now export the NFS definitions to make them available, then re-start NFS"
echo ""
set -x
sudo exportfs -rav
sleep 2s
sudo systemctl stop nfs-kernel-server
sleep 2s
sudo systemctl restart nfs-kernel-server
sleep 2s
set +x
echo ""
echo "# Now list the content of the exported the definitions to check they are available"
echo ""
set -x
sudo ls -al "${root_folder_1}" 
sudo ls -al "${nfs_export_full_1}" 
set +x
if [ "${SecondDisk}" = "y" ]; then
	set -x
	sudo ls -al "${root_folder_2}" 
	sudo ls -al "${nfs_export_full_2}" 
	set +x
fi
set +x
echo ""
echo "Now cleanup NFS stuff ..."
echo ""



set -x
cd ~/Desktop
f_ls_nsf=~/Desktop/ls-nsf.sh
sudo rm -vf "${f_ls_nsf}"
echo "#!/bin/bash:" >>"${f_ls_nsf}"
echo "# to get rid of MSDOS format do this to this file: sudo sed -i.bak s/\\r//g ./filename" >>"${f_ls_nsf}"
echo "# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save" >>"${f_ls_nsf}"
echo "#" >>"${f_ls_nsf}"
echo "# Connect to and list the content of local NFS file shares " >>"${f_ls_nsf}"
echo "#" >>"${f_ls_nsf}"
sudo umount -f "/tmp-NFS-mountpoint"
echo sudo umount -f "/tmp-NFS-mountpoint">>"${f_ls_nsf}"
sudo mkdir -p "/tmp-NFS-mountpoint"
echo sudo mkdir -p "/tmp-NFS-mountpoint">>"${f_ls_nsf}"
sudo chmod -c a=rwx -R "/tmp-NFS-mountpoint"
echo sudo chmod -c a=rwx -R "/tmp-NFS-mountpoint">>"${f_ls_nsf}"
#sudo ls -al "/tmp-NFS-mountpoint"
sudo mount -v -t nfs ${server_ip}:/${nfs_export_full_1} "/tmp-NFS-mountpoint"
echo sudo mount -v -t nfs ${server_ip}:/${nfs_export_full_1} "/tmp-NFS-mountpoint">>"${f_ls_nsf}"
sudo ls -al "/tmp-NFS-mountpoint/"
echo # list files in the main share ">>"${f_ls_nsf}"
echo sudo ls -al "/tmp-NFS-mountpoint/">>"${f_ls_nsf}"
sudo umount -f "/tmp-NFS-mountpoint"
echo sudo umount -f "/tmp-NFS-mountpoint">>"${f_ls_nsf}"
if [ "${SecondDisk}" = "y" ]; then
	sudo umount -f "/tmp-NFS-mountpoint2"
	echo sudo umount -f "/tmp-NFS-mountpoint2">>"${f_ls_nsf}"
	sudo mkdir -p "/tmp-NFS-mountpoint2"
	echo sudo mkdir -p "/tmp-NFS-mountpoint2">>"${f_ls_nsf}"
	sudo chmod -c a=rwx -R "/tmp-NFS-mountpoint2"
	echo sudo chmod -c a=rwx -R "/tmp-NFS-mountpoint2">>"${f_ls_nsf}"
	#sudo ls -al "/tmp-NFS-mountpoint2"
	sudo mount -v -t nfs ${server_ip}:/${nfs_export_full_2} "/tmp-NFS-mountpoint2"
	echo sudo mount -v -t nfs ${server_ip}:/${nfs_export_full_2} "/tmp-NFS-mountpoint2">>"${f_ls_nsf}"
	sudo ls -al "/tmp-NFS-mountpoint2/"
	echo # list files in the secondary share ">>"${f_ls_nsf}"
	echo sudo ls -al "/tmp-NFS-mountpoint2/">>"${f_ls_nsf}"
	sudo umount -f "/tmp-NFS-mountpoint2"
	echo sudo umount -f "/tmp-NFS-mountpoint2">>"${f_ls_nsf}"
fi
#sudo rm -vf "/tmp-NFS-mountpoint"
# do NOT remove the mountpoint as it may accidentally wipe the mounted drive !!!
set +x
#
echo ""
echo "# If theNFS  cleanup did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
echo "################################################################################################################################"
echo ""
echo "#-------------------------------------------------------------------------------------------------------------------------------------"













#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "We have now completed PART 2 of the setup."
echo ""
echo "Now we will now reboot the Pi4, so that things are running cleanly."
echo ""
read -p "# Press Enter to continue."
echo ""
set -x
sudo reboot now
set +x
exit


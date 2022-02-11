#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i.bak s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo "# THis is now the x64 version for Raspberry Pi OS x64 - and ONLY the x64 version"
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo "#"
set -x
do_setup_hdidle=false
do_setup_NFS=false
do_setup_SAMBA=false
do_setup_miniDLNA=true
set +x
echo "#"
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
if [[ "${OK}" = "n" ]]; then
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
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
while true; do
	read -p "Have you plugged in the USB3 external disk(s) into the correct USB3 slots yet ? [y/n]? " yn
	case $yn in
		[Yy]* ) OK=y; break;;
		[Nn]* ) OK=n; break;;
		* ) echo "Please answer y or n only.";;
	esac
done
if [[ "${OK}" = "n" ]]; then
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
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Ask for and setup default settings and try to remember them."
echo ""
sdname=./setupNAS_ask_defaults.sh
echo source "${sdname}"
##. "${sdname}" ### Yes there's a ". " at the start of the line '. "${sdname}"'
set -x
source "${sdname}"
set +x
echo ""
#
#############################################################################################################################################
if [[ ${do_setup_hdidle} = true ]]; then
#############################################################################################################################################
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
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
if [[ "${SecondDisk}" = "y" ]]; then
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
if [[ "${SecondDisk}" = "y" ]]; then
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
sleep 2s
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
if [[ "${SecondDisk}" = "y" ]]; then
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
sleep 2s
sudo cat /var/log/hd-idle.log
set +x
echo ""
echo "# Finished installation of hd-idle so that external USB3 disks spin down when idle and not wear out quickly."
echo ""
#
#############################################################################################################################################
fi ### if [[ ${do_setup_hdidle} ]]; then
#############################################################################################################################################
#
#
#############################################################################################################################################
if [[ ${do_setup_NFS} = true ]]; then
#############################################################################################################################################
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
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
if [[ "${SecondDisk}" = "y" ]]; then
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
sleep 2s
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
if [[ "${SecondDisk}" = "y" ]]; then
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
sleep 2s
sudo systemctl restart nfs-kernel-server
sleep 2s
set +x
echo ""
echo "# Manually mount the NFS shares (they are not yet in fstab)"
echo ""
set -x
sudo df -h
sudo mount -l
## mount physical logical
sudo mount -v --bind "${root_folder_1}" "${nfs_export_full_1}" --options defaults,nofail,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=$(id -r -u pi),gid=$(id -r -g pi),noatime,nodiratime,x-systemd.device-timeout=120
sudo ls -al "${root_folder_1}" 
sudo ls -al "${nfs_export_full_1}" 
set +x
if [[ "${SecondDisk}" = "y" ]]; then
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
## physical logical
sudo sed -iBAK "$ a ${root_folder_1} ${nfs_export_full_1} none bind,defaults,nofail,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=$(id -r -u pi),gid=$(id -r -g pi),noatime,nodiratime,x-systemd.device-timeout=120 0 0" "/etc/fstab"
set +x
if [[ "${SecondDisk}" = "y" ]]; then
	set -x
	## physical logical
	sudo sed -iBAK "$ a ${root_folder_2} ${nfs_export_full_2} none bind,defaults,nofail,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=$(id -r -u pi),gid=$(id -r -g pi),noatime,nodiratime,x-systemd.device-timeout=120 0 0" "/etc/fstab"
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
set -x
##sudo sed -i "$ a ${nfs_export_top} ${server_ip}/24(rw,insecure,sync,no_subtree_check,all_squash,crossmnt,fsid=0,root_squash,anonuid=$(id -r -u pi),anongid=$(id -r -g pi))" "/etc/exports"
sudo sed -i "$ a ${nfs_export_full_1} ${server_ip}/24(rw,insecure,sync,no_subtree_check,all_squash,crossmnt,anonuid=$(id -r -u pi),anongid=$(id -r -g pi))" "/etc/exports"
set +x
if [[ "${SecondDisk}" = "y" ]]; then
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
if [[ "${SecondDisk}" = "y" ]]; then
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
if [[ "${SecondDisk}" = "y" ]]; then
	set -x
	sudo ls -al "${root_folder_2}" 
	sudo ls -al "${nfs_export_full_2}" 
	set +x
fi
set +x
#++++++++++
echo ""
echo "Create a .sh to test NFS stuff at any time, mounting and dismounting shares ..."
echo ""
f_ls_nsf=./test_nsf.sh
set -x
cd ~/Desktop
sudo rm -vf "${f_ls_nsf}"
temp_remote_nfs_share_1="/temp_remote_nfs_share_1"
temp_remote_nfs_share_2="/temp_remote_nfs_share_2"
set +x
echo "#!/bin/bash" >>"${f_ls_nsf}"
echo "# to get rid of MSDOS format do this to this file: sudo sed -i.bak s/\\r//g ./filename" >>"${f_ls_nsf}"
echo "# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save" >>"${f_ls_nsf}"
echo "#" >>"${f_ls_nsf}"
echo "set -x" >>"${f_ls_nsf}"
echo "#" >>"${f_ls_nsf}"
echo "# Connect to and list the content of local NFS file shares " >>"${f_ls_nsf}"
echo "#" >>"${f_ls_nsf}"
echo "cd ~/Desktop">>"${f_ls_nsf}"
echo "#">>"${f_ls_nsf}"
echo "# Dismount the connections to the remote NFS share(s) in case they area already mounted">>"${f_ls_nsf}"
echo "#">>"${f_ls_nsf}"
echo "sudo umount -f \"${temp_remote_nfs_share_1}\"">>"${f_ls_nsf}"
if [[ "${SecondDisk}" = "y" ]]; then
	echo "sudo umount -f \"${temp_remote_nfs_share_2}\"">>"${f_ls_nsf}"
fi
echo "#">>"${f_ls_nsf}"
echo "# Create the local files to be used as temporary share mount points to connect to the remote NFS shares">>"${f_ls_nsf}"
echo "#">>"${f_ls_nsf}"
echo "sudo mkdir -pv \"${temp_remote_nfs_share_1}\"">>"${f_ls_nsf}"
echo "sudo chmod -c a=rwx -R \"${temp_remote_nfs_share_1}\"">>"${f_ls_nsf}"
if [[ "${SecondDisk}" = "y" ]]; then
	echo "sudo mkdir -pv \"${temp_remote_nfs_share_2}\"">>"${f_ls_nsf}"
	echo "sudo chmod -c a=rwx -R \"${temp_remote_nfs_share_2}\"">>"${f_ls_nsf}"
fi
echo "#">>"${f_ls_nsf}"
echo "# Connect to the remote NFS share(s) using the temporary mount points">>"${f_ls_nsf}"
echo "#">>"${f_ls_nsf}"
echo "sudo df -h">>"${f_ls_nsf}"
echo "sudo mount -l">>"${f_ls_nsf}"
echo "sudo mount -v -t nfs ${server_ip}:${nfs_export_full_1} \"${temp_remote_nfs_share_1}\"">>"${f_ls_nsf}"
echo "# list files in the local folder ">>"${f_ls_nsf}"
echo "sudo ls -al \"${root_folder_1}\"">>"${f_ls_nsf}"
echo "# list files in the NFS share, which SHOULD be the same as in the local folder ">>"${f_ls_nsf}"
echo "sudo ls -al \"${temp_remote_nfs_share_1}\"">>"${f_ls_nsf}"
echo "# dismount the temporary NFS share">>"${f_ls_nsf}"
echo "sudo umount -f \"${temp_remote_nfs_share_1}\"">>"${f_ls_nsf}"
echo "# do NOT NOT remove the mountpoint as it may accidentally wipe the mounted drive !!!">>"${f_ls_nsf}"
echo "###sudo rm -vf \"${temp_remote_nfs_share_1}\"">>"${f_ls_nsf}"
if [[ "${SecondDisk}" = "y" ]]; then
	echo "sudo mount -v -t nfs ${server_ip}:${nfs_export_full_2} \"${temp_remote_nfs_share_2}\"">>"${f_ls_nsf}"
	echo "# list files in the local folder ">>"${f_ls_nsf}"
	echo "sudo ls -al \"${root_folder_2}\"">>"${f_ls_nsf}"
	echo "# list files in the NFS share, which SHOULD be the same as in the local folder ">>"${f_ls_nsf}"
	echo "sudo ls -al \"${temp_remote_nfs_share_2}\"">>"${f_ls_nsf}"
	echo "# dismount the temporary NFS share">>"${f_ls_nsf}"
	echo "sudo umount -f \"${temp_remote_nfs_share_2}\"">>"${f_ls_nsf}"
	echo "# do NOT NOT remove the mountpoint as it may accidentally wipe the mounted drive !!!">>"${f_ls_nsf}"
	echo "###sudo rm -vf \"${temp_remote_nfs_share_2}\"">>"${f_ls_nsf}"
fi
echo ""
# OK, let's test the NFS shares
set -x
cd ~/Desktop
source "${f_ls_nsf}"
set +x
echo ""
#
#############################################################################################################################################
fi ### if [[ ${do_setup_NFS} ]]; then
#############################################################################################################################################
#
#
#############################################################################################################################################
if [[ ${do_setup_SAMBA} = true ]]; then
#############################################################################################################################################
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Install SAMBA and create the smb file shares accessible by Windows"
echo ""
echo "# First Un-Install any previous SAMBA install and then Install it ..."
echo ""
set -x
sudo systemctl stop smbd
sudo apt purge -y --allow-unauthenticated --allow-remove-essential winbind samba-common samba cifs-utils smbclient
sudo apt autoremove -y
sudo apt-cache show samba
sudo rm -vf "/etc/samba/smb.conf"
sudo rm -vf "/etc/samba/smb.conf.old"
sudo rm -vfR "/etc/samba"
sudo rm -vfR "/var/lib/samba"
sudo rm -vfR "/usr/share/samba"
#sudo rm -vf "/etc/rc*.d/*samba" "/etc/init.d/samba"
sudo apt install -y             --fix-broken --fix-missing --allow-unauthenticated winbind samba-common samba cifs-utils smbclient
sudo apt install -y --reinstall --fix-broken --fix-missing --allow-unauthenticated winbind samba-common samba cifs-utils smbclient
sudo apt-cache show samba
set +x
echo ""
echo "# Create a SAMBA password for user 'pi' and for user 'root'"
echo ""
echo "# Before we start the server, you’ll want to set a Samba password. Enter your pi password."
echo "# Before we start the server, you’ll want to set a Samba password. Enter your pi password."
set -x
sudo smbpasswd -a pi
sudo smbpasswd -a root
set +x
echo ""
set -x
cd ~/Desktop
sudo rm -vf "./smb.conf"
# copy the modified version of smb.conf from github to ./
url="https://raw.githubusercontent.com/hydra3333/Pi4NAS/master/smb.conf"
curl -4 -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Cache-Control: max-age=0' "$url" --retry 50 -L --output "./smb.conf" --fail # -L means "allow redirection" or some odd :|
sudo cp -fv "./smb.conf"  "./smb.conf.old"
set +x
echo "Start appending stuff to temporary local file copy of 'smb.conf' ..."
echo "[${virtual_folder_name_1}]">>"./smb.conf"
echo "comment=${server_name} ${virtual_folder_name_1} home">>"./smb.conf"
echo "#force group = users">>"./smb.conf"
echo "#guest only = Yes">>"./smb.conf"
echo "guest ok = Yes">>"./smb.conf"
echo "public = yes">>"./smb.conf"
echo "#valid users = @users">>"./smb.conf"
echo "path = ${USB3_mountpoint_1}">>"./smb.conf"
echo "available = yes">>"./smb.conf"
echo "read only = no">>"./smb.conf"
echo "browsable = yes">>"./smb.conf"
echo "writeable = yes">>"./smb.conf"
echo "#create mask = 0777">>"./smb.conf"
echo "#directory mask = 0777">>"./smb.conf"
echo "force create mode = 1777">>"./smb.conf"
echo "force directory mode = 1777">>"./smb.conf"
echo "inherit permissions = yes">>"./smb.conf"
echo "# 2022.02.06">>"./smb.conf"
echo "allow insecure wide links = yes">>"./smb.conf"
echo "follow symlinks = yes">>"./smb.conf"
echo "wide links = yes">>"./smb.conf"
echo "">>"./smb.conf"
if [ "${SecondDisk}" = "y" ]; then
	echo "[${virtual_folder_name_2}]">>"./smb.conf"
	echo "comment=${server_name} ${virtual_folder_name_2} home">>"./smb.conf"
	echo "#force group = users">>"./smb.conf"
	echo "#guest only = Yes">>"./smb.conf"
	echo "guest ok = Yes">>"./smb.conf"
	echo "public = yes">>"./smb.conf"
	echo "#valid users = @users">>"./smb.conf"
	echo "path = ${USB3_mountpoint_2}">>"./smb.conf"
	echo "available = yes">>"./smb.conf"
	echo "read only = no">>"./smb.conf"
	echo "browsable = yes">>"./smb.conf"
	echo "writeable = yes">>"./smb.conf"
	echo "#create mask = 0777">>"./smb.conf"
	echo "#directory mask = 0777">>"./smb.conf"
	echo "force create mode = 1777">>"./smb.conf"
	echo "force directory mode = 1777">>"./smb.conf"
	echo "inherit permissions = yes">>"./smb.conf"
	echo "# 2022.02.06">>"./smb.conf"
	echo "allow insecure wide links = yes">>"./smb.conf"
	echo "follow symlinks = yes">>"./smb.conf"
	echo "wide links = yes">>"./smb.conf"
	echo "">>"./smb.conf"
fi
echo "Finished appending stuff to temporary local file copy of 'smb.conf' ..."
echo "Copy the updated 'smb.conf' to '/etc/samba/smb.conf' ..."
set -x
sudo chmod -c a=rwx -R *
sudo rm -vf "/etc/samba/smb.conf.old"
sudo cp -vf "/etc/samba/smb.conf" "/etc/samba/smb.conf.old"
sudo cp -vf "./smb.conf" "/etc/samba/smb.conf"
sudo chmod -c a=rwx -R "/etc/samba"
sudo cat "/etc/samba/smb.conf"
sudo diff -U 10 "/etc/samba/smb.conf.old" "/etc/samba/smb.conf"
set +x
echo ""
echo "# Test that the samba config is OK"
echo "# ignore this: # rlimit_max: increasing rlimit_max (1024) to minimum Windows limit (16384) ..."
echo ""
set -x
sudo testparm
set +x
echo ""
echo "# Restart Samba service"
echo ""
set -x
sudo systemctl enable smbd
sleep 2s
sudo systemctl stop smbd
sleep 2s
sudo systemctl restart smbd
sleep 2s
set +x
echo ""
echo "# List the new Samba users (which can have different passwords to the Pi itself) and shares"
echo ""
set -x
sudo pdbedit -L -v
sudo net usershare info --long
sudo smbstatus
sudo smbstatus --shares # Will retrieve what's being shared and which machine (if any) is connected to what.
#sudo net rpc share list -U pi
#sudo net rpc share list -U root
#sudo smbclient -L host
#sudo smbclient -L ${server_ip} -U pi
#sudo smbclient -L ${server_ip} -U root
set +x
echo ""
echo "You can now access the defined shares from a Windows machine or from an app that supports the SMB protocol"
echo "eg from Win10 PC in Windows Explorer use the IP address of ${server_name} like ... \\\\${server_ip}\\ "
set -x
sudo hostname
sudo hostname --fqdn
sudo hostname --all-ip-addresses
set +x
echo ""
#
#############################################################################################################################################
fi ### if [[ ${do_setup_SAMBA} ]]; then
#############################################################################################################################################
#
#
#############################################################################################################################################
if [[ ${do_setup_miniDLNA} = true ]]; then
#############################################################################################################################################
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Install miniDLNA and modify the conf to use the folders we need to index."
echo ""
echo "NOTE: this miniDLNA setup is SPECIFIC to my media drive(s) sets of folders !!!"
echo "NOTE: this miniDLNA setup is SPECIFIC to my media drive(s) sets of folders !!!"
echo "NOTE: this miniDLNA setup is SPECIFIC to my media drive(s) sets of folders !!!"
echo "NOTE: this miniDLNA setup is SPECIFIC to my media drive(s) sets of folders !!!"
echo "NOTE: this miniDLNA setup is SPECIFIC to my media drive(s) sets of folders !!!"
echo "NOTE: this miniDLNA setup is SPECIFIC to my media drive(s) sets of folders !!!"
echo "NOTE: this miniDLNA setup is SPECIFIC to my media drive(s) sets of folders !!!"
echo "NOTE: this miniDLNA setup is SPECIFIC to my media drive(s) sets of folders !!!"
echo "NOTE: this miniDLNA setup is SPECIFIC to my media drive(s) sets of folders !!!"
echo ""
echo ""
echo "# Increase fs.inotify.max_user_watches from default 8192 (used by miniDLNA)"
max_user_watches=262144
echo "# Per https://wiki.debian.org/minidlna and https://wiki.archlinux.org/title/ReadyMedia"
echo "# To avoid Inotify errors, Increase the number for the system :"
echo "# In /etc/sysctl.conf Add: 'fs.inotify.max_user_watches=${max_user_watches}' in a blank line by itself."
echo "# Increase system max_user_watches to avoid this error:"
echo "# WARNING: Inotify max_user_watches [8192] is low or close to the number of used watches [2] and I do not have permission to increase this limit.  Please do so manually by writing a higher value into /proc/sys/fs/inotify/max_user_watches."
echo ""
echo "# set a new TEMPORARY limit with:"
# sudo sed -i.bak "s;8192;${max_user_watches};g" "/proc/sys/fs/inotify/max_user_watches" # this fails with no permissions
set -x
sudo cat /proc/sys/fs/inotify/max_user_watches
sudo sysctl fs.inotify.max_user_watches=${max_user_watches}
sudo sysctl -p
set +x
echo ""
echo "# set a new PERMANENT limit with:"
set -x
sudo sed -i.bak "s;fs.inotify.max_user_watches=;#fs.inotify.max_user_watches=;g" "/etc/sysctl.conf"
echo fs.inotify.max_user_watches=${max_user_watches} | sudo tee -a "/etc/sysctl.conf"
sudo sysctl -p
set +x
echo ""
echo ""
echo "# Un-Install any prior minDLNA"
echo ""
set -x
sudo apt purge minidlna -y
sudo apt autoremove -y
sudo rm -vfR "/etc/minidlna.conf"
sudo rm -vfR "/var/log/minidlna.log"
sudo rm -vfR "/run/minidlna"
sudo rm -vfR "${server_root_USBmountpoint}/minidlna"
set +x
echo ""
echo "# Do the minidlna install and the stop the service so we can configure it"
echo ""
set -x
sudo apt install -y minidlna
sleep 2s
sudo systemctl enable minidlna
sleep 2s
sudo systemctl stop minidlna
sleep 2s
set +x
echo ""
echo "# Add minidlna Groups, then Create a folder for minidlna logs and db - place the folder in the root of the FIRST external USB3 disk"
echo ""
set -x
set minidlna_root_folder="${USB3_mountpoint_1}/minidlna"
sudo usermod -a -G pi minidlna
sudo usermod -a -G minidlna pi
sudo usermod -a -G minidlna root
sudo mkdir -p "${minidlna_root_folder}"
sudo chmod -c a=rwx -R "${minidlna_root_folder}"
sudo chown -c -R pi:minidlna "${minidlna_root_folder}"
sudo chmod -c a=rwx -R "/run/minidlna"
sudo chown -c -R pi:minidlna "/run/minidlna"
#sudo chmod -c a=rwx -R "/run/minidlna/minidlna.pid"
#sudo chown -c -R pi:minidlna "/run/minidlna/minidlna.pid"
sudo ls -al "/run/minidlna"
sudo chmod -c a=rwx -R "/etc/minidlna.conf"
sudo chown -c -R pi:minidlna "/etc/minidlna.conf"
sudo chmod -c a=rwx -R "/var/cache/minidlna"
sudo chown -c -R pi:minidlna "/var/cache/minidlna"
sudo chmod -c a=rwx -R "/var/log/minidlna.log"
sudo chown -c -R pi:minidlna "/var/log/minidlna.log"
set +x
echo ""
echo "# Change miniDLNA config settings"
echo ""
set -x
minidlna_db_dir="${minidlna_root_folder}"
minidlna_log_dir="${minidlna_root_folder}"
minidlna_sh_dir="${minidlna_root_folder}"
minidlna_main_log_file=${minidlna_log_dir}/minidlna.log
minidlna_refresh_log_file=${minidlna_log_dir}/minidlna_refresh.log
minidlna_refresh_sh_file=${minidlna_sh_dir}/minidlna_refresh.sh
minidlna_restart_refresh_sh_file=~/Desktop/minidlna_restart_refresh.sh
sudo cp -fv "/etc/minidlna.conf" "/etc/minidlna.conf.old"
sudo sed -i "s;#user=minidlna;#user=minidlna\n#user=pi;g" "/etc/minidlna.conf"
sudo sed -i "s;#db_dir=/var/cache/minidlna;#db_dir=/var/cache/minidlna\ndb_dir=${minidlna_db_dir};g" "/etc/minidlna.conf"
sudo sed -i "s;#log_dir=/var/log/minidlna;#log_dir=/var/log/minidlna\nlog_dir=${minidlna_log_dir};g" "/etc/minidlna.conf"
sudo sed -i "s;#friendly_name=;#friendly_name=\nfriendly_name=${server_name}-minidlna;g" "/etc/minidlna.conf"
sudo sed -i "s;#inotify=yes;#inotify=yes\ninotify=yes;g" "/etc/minidlna.conf"
sudo sed -i "s;#strict_dlna=no;#strict_dlna=no\nstrict_dlna=yes;g" "/etc/minidlna.conf"
sudo sed -i "s;#notify_interval=895;#notify_interval=895\nnotify_interval=900;g" "/etc/minidlna.conf"
sudo sed -i "s;#max_connections=50;#max_connections=50\nmax_connections=6;g" "/etc/minidlna.conf"
sudo sed -i "s;#log_level=general,artwork,database,inotify,scanner,metadata,http,ssdp,tivo=warn;#log_level=general,artwork,database,inotify,scanner,metadata,http,ssdp,tivo=warn\nlog_level=general,artwork,database,inotify,scanner,metadata,http,ssdp,tivo=info;g" "/etc/minidlna.conf"
sudo sed -i "s;#wide_links=no;wide_links=yes;g" "/etc/minidlna.conf"
sudo sed -i "s;album_art_names=;#album_art_names=;g" "/etc/minidlna.conf"
set +x
echo ""
echo "# Change miniDLNA folders SPECIFIC to my media drive(s) sets of folders !!! For me only !!!"
echo "# Change miniDLNA folders SPECIFIC to my media drive(s) sets of folders !!! For me only !!!"
echo "# Change miniDLNA folders SPECIFIC to my media drive(s) sets of folders !!! For me only !!!"
echo ""
set -x
sudo sed -i "s;media_dir=/var/lib/minidlna;#media_dir=/var/lib/minidlna\n###---###'g" "/etc/minidlna.conf"
sudo sed '/^###---###$/r'<(
	echo "media_dir=PVA,${root_folder_1}/2015.11.29-Jess-21st-birthday-party"
	echo "media_dir=PVA,${root_folder_1}/BigIdeas"
	echo "media_dir=PVA,${root_folder_1}/CharlieWalsh"
	echo "media_dir=PVA,${root_folder_1}/ClassicDocumentaries"
	echo "media_dir=PVA,${root_folder_1}/ClassicMovies"
	echo "media_dir=PVA,${root_folder_1}/Documentaries"
	echo "media_dir=PVA,${root_folder_1}/movies"
	echo "media_dir=PVA,${root_folder_1}/OldMovies"
	echo "media_dir=PVA,${root_folder_1}/OldSciFi"
	echo "media_dir=PVA,${root_folder_2}/movies"
	echo "media_dir=PVA,${root_folder_2}/MusicVideos"
	echo "media_dir=PVA,${root_folder_2}/Railway_Journeys"
	echo "media_dir=PVA,${root_folder_2}/Series"
) -i -- "/etc/minidlna.conf"
sudo cat "/etc/minidlna.conf"
sudo diff -U 10 "/etc/minidlna.conf.old" "/etc/minidlna.conf"
set +x
echo ""
sudo rm -vf "${minidlna_main_log_file}"
sudo rm -vf "${minidlna_refresh_log_file}"
sudo touch "${minidlna_refresh_log_file}"
echo ""
echo "Create the .sh used by crontab to refresh the db every night. ${minidlna_refresh_sh_file}"
echo ""
sudo rm -vf "${minidlna_refresh_sh_file}"
sudo touch "${minidlna_refresh_sh_file}"
sudo chmod -c a=rwx "${minidlna_refresh_sh_file}"
echo "#!/bin/bash" >> "${minidlna_refresh_sh_file}"
echo "set -x" >> "${minidlna_refresh_sh_file}"
echo "# ${minidlna_refresh_sh_file}" >> "${minidlna_refresh_sh_file}"
echo "# used by crontab to refresh the the db every night" >> "${minidlna_refresh_sh_file}"
echo "sudo systemctl stop minidlna" >> "${minidlna_refresh_sh_file}"
echo "sleep 2s" >> "${minidlna_refresh_sh_file}"
echo "sudo systemctl restart minidlna" >> "${minidlna_refresh_sh_file}"
echo "sleep 2s" >> "${minidlna_refresh_sh_file}"
echo "echo 'Wait 15 minutes for minidlna to index media files'" >> "${minidlna_refresh_sh_file}"
echo "echo 'For progress do in another terminal window: cat ${main_log_dir}'" >> "${minidlna_refresh_sh_file}"
echo "sleep 900s" >> "${minidlna_refresh_sh_file}"
echo "set +x" >> "${minidlna_refresh_sh_file}"
echo "# ${minidlna_refresh_sh_file}" >> "${minidlna_refresh_sh_file}"
echo ""
echo "Create the .sh used by a user to manually refresh the the db. ${minidlna_restart_refresh_sh_file}"
echo ""
sudo rm -vf "${minidlna_restart_refresh_sh_file}"
sudo touch "${minidlna_restart_refresh_sh_file}"
sudo chmod -c a=rwx "${minidlna_restart_refresh_sh_file}"
echo "#!/bin/bash" >> "${minidlna_restart_refresh_sh_file}"
echo "set -x" >> "${minidlna_restart_refresh_sh_file}"
echo "# ${minidlna_restart_refresh_sh_file}" >> "${minidlna_restart_refresh_sh_file}"
echo "# used in ~/Desktop for a user to manually refresh the the db" >> "${minidlna_restart_refresh_sh_file}"
echo "sudo systemctl stop minidlna" >> "${minidlna_restart_refresh_sh_file}"
echo "sleep 2s" >> "${minidlna_restart_refresh_sh_file}"
echo "sudo systemctl restart minidlna" >> "${minidlna_restart_refresh_sh_file}"
echo "sleep 2s" >> "${minidlna_restart_refresh_sh_file}"
echo "echo 'Wait 15 minutes for minidlna to index media files'" >> "${minidlna_restart_refresh_sh_file}"
echo "echo 'For progress do in another terminal window: cat ${main_log_dir}'" >> "${minidlna_restart_refresh_sh_file}"
echo "sleep 900s" >> "${minidlna_restart_refresh_sh_file}"
echo "#" >> "${minidlna_restart_refresh_sh_file}"
echo "cat \"${minidlna_main_log_file}\"" >> "${minidlna_restart_refresh_sh_file}"
echo "#" >> "${minidlna_restart_refresh_sh_file}"
echo "set +x" >> "${minidlna_restart_refresh_sh_file}"
echo "set +x" >> "${minidlna_restart_refresh_sh_file}"
echo "# ${minidlna_restart_refresh_sh_file}" >> "${minidlna_restart_refresh_sh_file}"
echo ""
echo "Add the 2:00 am nightly crontab job to re-index miniDLNA (${})"
echo ""
# https://stackoverflow.com/questions/610839/how-can-i-programmatically-create-a-new-cron-job
#The layout for a cron entry is made up of six components: minute, hour, day of month, month of year, day of week, and the command to be executed.
# m h  dom mon dow   command
# * * * * *  command to execute
# ┬ ┬ ┬ ┬ ┬
# │ │ │ │ │
# │ │ │ │ │
# │ │ │ │ └───── day of week (0 - 7) (0 to 6 are Sunday to Saturday, or use names; 7 is Sunday, the same as 0)
# │ │ │ └────────── month (1 - 12)
# │ │ └─────────────── day of month (1 - 31)
# │ └──────────────────── hour (0 - 23)
# └───────────────────────── min (0 - 59)
# https://stackoverflow.com/questions/610839/how-can-i-programmatically-create-a-new-cron-job
# <minute> <hour> <day> <month> <dow> <tags and command>
echo "# crontab List BEFORE contab ADD:"
set -x
sudo crontab -l # before
crontab -l # before
set +x
echo "# Adding crontab as user pi (no sudo):"
set -x
( crontab -l ; echo "0 2 * * * ${minidlna_refresh_sh_file} 2>&1 >> ${log_file}" ) 2>&1 | sed "s/no crontab for $(whoami)//g" | sort - | uniq - | crontab -
set +x
echo "#"
echo "# crontab List AFTER contab ADD:"
set -x
sudo crontab -l # after
crontab -l # before
set +x
echo "# syslog AFTER contab ADD:"
set -x
sudo grep CRON /var/log/syslog
set +x
echo ""
echo "# Start miniDLNA: Force a re-load of miniDLNA to ensure it starts re-looking for new files."
echo ""
set -x
sudo ls -al "/run/minidlna"
sudo systemctl stop minidlna
sleep 2s
sudo systemctl restart minidlna
sleep 2s
set +x
echo "#"
echo "# The minidlna service comes with a small webinterface. "
echo "# This webinterface is just for informational purposes. "
echo "# You will not be able to configure anything here. "
echo "# However, it gives you a nice and short information screen how many files have been found by minidlna. "
echo "# minidlna comes with it’s own webserver integrated. "
echo "# This means that no additional webserver is needed in order to use the webinterface."
echo "# To access the webinterface, open your browser of choice and enter url http://127.0.0.1:8200"
echo ""
set -x
curl -i http://127.0.0.1:8200
set +x
echo ""
# The actual streaming process
# A short overview how a connection from a client to the configured and running minidlna server could work. 
# In this scenario we simply use a computer which is in the same local area network than the server. 
# As the client software we use the Video Lan Client (VLC). 
# Simple, robust, cross-platform and open source. 
# After starting VLC, go to the playlist mode by pressing CTRL+L in windows. 
# You will now see on the left side a category which is called Local Network. 
# Click on Universal Plug’n’Play which is under the Local Network category. 
# You will then see a list of available DLNA service within your local network. 
# In this list you should see your DLNA server. 
# Navigate through the different directories for music, videos and pictures and select a file to start the streaming process
echo ""
#
set -x
sudo ls -al "/run/minidlna"
set +x
echo ""
set -x
sudo ls -al "${minidlna_main_log_file}"
sudo cat "${minidlna_main_log_file}"
set +x
echo ""
set -x
sudo ls -al "${minidlna_refresh_log_file}"
sudo cat "${minidlna_refresh_log_file}"
set +x
echo ""
#
#############################################################################################################################################
fi ### if [[ ${do_setup_miniDLNA} ]]; then
#############################################################################################################################################
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
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


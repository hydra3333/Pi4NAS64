#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i.bak s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#

echo "############# UNDER CONSTRUCTION"
echo "############# UNDER CONSTRUCTION"
echo "############# UNDER CONSTRUCTION"
echo "############# UNDER CONSTRUCTION"
echo "############# UNDER CONSTRUCTION"
echo "############# UNDER CONSTRUCTION"
exit


set -x
cd ~/Desktop
set +x

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "# Have we completed the pre-Install set of instructions per the Readme ?"
echo "# If not, control-C then do them, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "OK, please visually check some settings on the Pi4"
echo ""
set -x
sudo dhclient -r
sudo dhclient
sudo ifconfig
sudo hostname
sudo hostname --fqdn
sudo hostname --all-ip-addresses
set +x
echo ""
echo "# Check the fixed IP Address and Host name etc."
echo "# If not OK, control-C, then redo the pre-Install stuff, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "# Find and note EXACTLY the correct UUID= string and physical mount point string for the USB3 external hard drive(s)"
echo ""
echo "# The next commands should yield something a bit like this"
echo '# /dev/mmcblk0p1: LABEL_FATBOOT="boot" LABEL="boot" UUID="69D5-9B27" TYPE="vfat" PARTUUID="d9b3f436-01"'
echo '# /dev/mmcblk0p2: LABEL="rootfs" UUID="24eaa08b-10f2-49e0-8283-359f7eb1a0b6" TYPE="ext4" PARTUUID="d9b3f436-02"'
echo '# /dev/sda2: LABEL="5TB-mp4library" UUID="F8ACDEBBACDE741A" TYPE="ntfs" PTTYPE="atari" PARTLABEL="Basic data partition" PARTUUID="6cc8d3fb-6942-4b4b-a7b1-c31d864accef"'
echo '# /dev/mmcblk0: PTUUID="d9b3f436" PTTYPE="dos"'
echo '# /dev/sda1: PARTLABEL="Microsoft reserved partition" PARTUUID="62ac9e1a-a82b-4df7-92b9-19ffc689d80b"'
echo ""
echo "# Look for the Disk Label ... in the above case the UUID is F8ACDEBBACDE741A "
echo "# ... copy and paste the UUID string somewhere as we must use it later"
echo "# Then look for its physical mount point ... in this case it is /dev/sda2"
echo "# ... copy and paste the string somewhere as we must use it later"
echo "# With a second USB3 drive, both these would be obvious as well ... also copy and paste these strings somewhere as we must use them later"
echo ""
read -p "# Press Enter to see the values on this Pi4 continue."
echo ""
set -x
sudo df
sudo blkid 
set +x
echo ""
echo "# OK, see and copy the relevant UUID string(s) and physical mount point string(s)."
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
read -p "# Confirm default values for the Pi4 and USB3 drives.  Press Enter to continue."
echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"
# Ask for and setup default settings and try to remember them. Yes there's a ". " at the start of the line".
. "./setupNAS_ask_defaults"
echo "# ------------------------------------------------------------------------------------------------------------------------"
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "# Update /etc/apt/sources.list so that all standard repositories for o/s updates are allowed."
echo ""
set -x
# allow sources
sudo sed -i.bak "s/# deb/deb/g" "/etc/apt/sources.list"
set +x
echo "# If that did not work, control-C, then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "# Update the Rasbperry Pi4 Operating System with the latest patches."
echo ""
set -x
sudo apt update -y
sudo apt full-upgrade -y
set +x
echo ""
echo "# If that process requested we to Reboot the Pi4, control-C then Reboot then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "# Add 30 seconds for the USB3 drive to spin up during startup."
echo ""
# Add the line at the top. # per https://www.raspberrypi.org/documentation/configuration/config-txt/boot.md"
echo ""
echo "# Adding a line 'boot_delay=30' at the top of '/boot/config.txt'"
echo ""
#sudo sed -i.bak "1 i boot_delay=30" "/boot/config.txt" # doesn't work if the file has no line 1
set -x
sudo cp -fv "/boot/config.txt" "/boot/config.txt.old"
rm -f ./tmp.tmp
sudo sed -i.bak "/boot_delay/d" "/boot/config.txt"
echo "boot_delay=30" > ./tmp.tmp
sudo cat /boot/config.txt >> ./tmp.tmp
sudo cp -fv ./tmp.tmp /boot/config.txt
rm -f ./tmp.tmp
sudo diff -U 10 "/boot/config.txt.old" "/boot/config.txt"
cat "/boot/config.txt"
set +x
echo ""
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "Now,"
echo "# Use sudo raspi-config to check and if need be then set these options"
echo "# In Advanced Options"
echo "#   A5 Resolution "
echo "#      Choose 1920x1080 (and NOT 'default') "
echo "#      which magically enables VNC server to run even when a screen is not connected to the HDMI port"
echo "#   AA Video Output Video output options for Pi 4 "
echo "#      Enable 4Kp60 HDMI"
echo "#      Enable 4Kp60 resolution on HDMI0 (disables analog)"
echo "# Then check/change other settings"
echo "#"
echo "# (use <tab> and<enter> to move around raspi-config and choose menu items)"
echo "#"
read -p "# Press Enter to start sudo raspi-config to do that.  (exiting raspi-config will return here)"
echo ""
set -x
sudo raspi-config
set +x
echo ""
echo "# If that did not work or we were prompted to reboot, control-C then fix any issues and reboot, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "# Re-Update the Rasbperry Pi4 Operating System with the latest patches."
echo ""
set -x
sudo apt update -y
sudo apt full-upgrade -y
set +x
echo ""
echo "# If that process requested we to Reboot the Pi4, control-C then Reboot then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "# Fix user rights for user pi so that it has no trouble with mounting external drives."
read -p "# Press Enter to continue."
echo ""
set -x
sudo usermod -a -G plugdev pi
set +x
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "# OK ... PLEASE CONNECT THE EXTERNALLY-POWERED USB3 HARD DRIVE(S) INTO THE Pi4 NOW."
echo "# OK ... PLEASE CONNECT THE EXTERNALLY-POWERED USB3 HARD DRIVE(S) INTO THE Pi4 NOW."
echo ""
echo "# Always use the same USB socket on the Pi."
echo "# Always use an externally-powered  USB3 drive, so that we have "
echo "# sufficient power and sufficient data transfer bandwidth."
echo "# Once it spins up, the USB3 drive(s) will auto-mount with NTFS."
echo ""
read -p "# Press Enter to continue, after you have plugged them in and waited 30 seconds for them to auto-mount."
echo ""
echo "# Create a mount point folder(s) for the USB3 drive(s), which we'll use in a minute."
echo "# In this case I want to call it 'mp4library'"
echo ""
set -x
sudo mkdir -p ${server_root_USBmountpoint}
sudo chmod -c a=rwx -R ${server_root_USBmountpoint}
if [ "${SecondaryDisk}" = "y" ]; then
	sudo mkdir -p ${server_root_USBmountpoint2}
	sudo chmod -c a=rwx -R ${server_root_USBmountpoint2}
fi
set +x
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "# Just for kicks, see what filesystems are supported by the Pi4"
echo ""
set -x
ls -al "/lib/modules/$(uname -r)/kernel/fs/"
set +x
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "# **********************************************************************************************"
echo "# **********************************************************************************************"
echo "# **********************************************************************************************"
echo "# "
echo "# * THIS NEXT BIT IS VERY IMPORTANT - PLEASE LOOK CLOSELY AND ACT IF NECESSARY                  "
echo "# * THIS NEXT BIT IS VERY IMPORTANT - PLEASE LOOK CLOSELY AND ACT IF NECESSARY                  "
echo "# "
echo "# Now we add a line to file '/etc/fstab' so that USB3 drives are installed the same every time"
echo "# (remember, always be consistent and plugin the main USB3 drive into the bottom USB3 socket)"
echo "# https://wiki.debian.org/fstab"
echo "# "
echo "# **********************************************************************************************"
echo "# **********************************************************************************************"
echo "# **********************************************************************************************"
echo ""
read -p "# Press Enter to continue."
echo ""
set -x
sudo cp -fv "/etc/fstab" "/etc/fstab.old"
# put a "#" at the start of all lines containing this string: ntfs defaults,auto
sudo sed -i.bak "/ntfs defaults,auto/s/^/#/" "/etc/fstab"
#	"/ntfs defaults,auto/" matches a line with "ntfs defaults,auto"
#	s perform a substitution on the lines matched above (notice no "g" at the end of the "s" due to aforementioned line matching)
#	The substitution will insert a pound character (#) at the beginning of the line (^)
#	old subst fails with too many substitutes if server_USB3_DEVICE_UUID2 is blank : sudo sed -i.bak "s/UUID=${server_USB3_DEVICE_UUID}/#UUID=${server_USB3_DEVICE_UUID}/g" "/etc/fstab"
sudo sed -i.bak "$ a UUID=${server_USB3_DEVICE_UUID} ${server_root_USBmountpoint} ntfs defaults,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=$(id -r -u pi),gid=$(id -r -g pi),noatime,nodiratime,x-systemd.device-timeout=120 0 0" "/etc/fstab"
set +x
if [ "${SecondaryDisk}" = "y" ]; then
	set -x
	sudo sed -i.bak "s/UUID=${server_USB3_DEVICE_UUID2}/#UUID=${server_USB3_DEVICE_UUID2}/g" "/etc/fstab"
	sudo sed -i.bak "$ a UUID=${server_USB3_DEVICE_UUID2} ${server_root_USBmountpoint2} ntfs defaults,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=$(id -r -u pi),gid=$(id -r -g pi),noatime,nodiratime,x-systemd.device-timeout=120 0 0" "/etc/fstab"
	set +x
fi
set +x
echo ""
echo "# Please check '/etc/fstab' below NOW ... if it is incorrect then abort this process NOW and fix it manually"
echo "# Please check '/etc/fstab' below NOW ... if it is incorrect then abort this process NOW and fix it manually"
echo "# Please check '/etc/fstab' below NOW ... if it is incorrect then abort this process NOW and fix it manually"
echo ""
set -x
sudo diff -U 10 "/etc/fstab.old" "/etc/fstab" 
set +x
echo ""
set -x
sudo cat "/etc/fstab"
set +x
echo ""
echo "# If this is the first time this script is run please Control-C now and Reboot"
echo "# If this is the first time this script is run please Control-C now and Reboot"
echo "# If this is the first time this script is run please Control-C now and Reboot"
echo "# (So that the disks are mounted with the correct mount points"
echo "# Then after the Reboot, Re-run this script."
echo ""
read -p "# Eithe Control-C and Reboot, or Press Enter to continue" 
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "# Install a remote-printing feature so we can print from the Pi via the Windows 10 PC (see below)"
read -p "# Press Enter to continue."
echo ""
set -x
sudo apt install -y cups
set +x
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "# Install https for distros, although not strictly needed"
read -p "# Press Enter to continue."
echo ""
set -x
sudo apt install -y apt-transport-https
set +x
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "# Install the tool which can be used to turn EOL inside text files from windows type to unix type"
read -p "# Press Enter to continue."
echo ""
set -x
sudo apt install -y dos2unix
set +x
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "# Install the curl tool to download support files if required"
read -p "# Press Enter to continue."
echo ""
set -x
sudo apt install -y curl wget
set +x
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "# Get ready for IPv4 only, by disabling IPv6"
echo ""
set -x
sudo sysctl net.ipv6.conf.all.disable_ipv6=1 
sudo sysctl -p
sudo sed -i.bak "s;net.ipv6.conf.all.disable_ipv6;#net.ipv6.conf.all.disable_ipv6;g" "/etc/sysctl.conf"
echo net.ipv6.conf.all.disable_ipv6=1 | sudo tee -a "/etc/sysctl.conf"
sudo sysctl -p
set +x
echo ""
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "################################################################################################################################"
echo ""
echo "# Install 'hd-idle' so that external USB3 disks spin dowwn when idle and not wear out quickly."
read -p "# Press Enter to continue."
echo ""
echo "# Some WD external USB3 disks won't spin down on idle and HDPARM and SDPARM don't work on them."
echo "# ... hd-idle appears to work though, so let's use that."
echo ""
# https://www.htpcguides.com/spin-down-and-manage-hard-drive-power-on-raspberry-pi/
echo ""
echo "# **********************************************************************************************"
echo "# **********************************************************************************************"
echo "# **********************************************************************************************"
echo "# * THIS NEXT BIT IS VERY IMPORTANT - LOOK CLOSELY AND ACT IF NECESSARY                        "
echo "# * THIS NEXT BIT IS VERY IMPORTANT - LOOK CLOSELY AND ACT IF NECESSARY                        "
echo "# *                                                                                             "
echo "# **********************************************************************************************"
echo "# **********************************************************************************************"
echo "# **********************************************************************************************"
echo "#     server_USB3_DISK_NAME=${server_USB3_DISK_NAME}"
echo "#   server_USB3_DEVICE_NAME=${server_USB3_DEVICE_NAME}"
echo "#   server_USB3_DEVICE_UUID=${server_USB3_DEVICE_UUID}"
set -x
sudo blkid ${server_USB3_DEVICE_NAME}
sudo df ${server_USB3_DEVICE_NAME}
sudo lsblk ${server_USB3_DEVICE_NAME}
set +x
echo ""
echo "# List and Remove any prior hd-idle package"
echo ""
set -x
sudo dpkg -l hd-idle
sudo apt purge -y hd-idle
set +x
echo ""
echo "# Install hd-idle and dependencies"
echo ""
set -x
sudo apt-get install build-essential fakeroot debhelper -y
wget http://sourceforge.net/projects/hd-idle/files/hd-idle-1.05.tgz
tar -xvf hd-idle-1.05.tgz
cd hd-idle
dpkg-buildpackage -rfakeroot
sudo dpkg -i ../hd-idle_*.deb
cd ..
sudo dpkg -l hd-idle
set +x
echo ""
echo "# Configure hd-idle and dependencies"
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
echo "# Modify the hd-idle configuration file to enable the service to automatically start and spin down drives"
echo ""
set -x
the_default_timeout=300
the_sda_timeout=900
set +x
echo ""
set -x
sudo cp -fv "/etc/default/hd-idle" "/etc/default/hd-idle.old"
sudo sed -i "s;START_HD_IDLE=;#START_HD_IDLE=;g" "/etc/default/hd-idle"
sudo sed -i "s;HD_IDLE_OPTS=;#HD_IDLE_OPTS=;g" "/etc/default/hd-idle"
sudo sed -i "2 i START_HD_IDLE=true" "/etc/default/hd-idle" # insert at line 2
sudo sed -i "$ a HD_IDLE_OPTS=\"-i ${the_default_timeout} -a ${server_USB3_DISK_NAME} -i ${the_sda_timeout} -l /var/log/hd-idle.log\"" "/etc/default/hd-idle" # insert as last line
if [ "${SecondaryDisk}" = "y" ]; then
	sudo sed -i "$ a HD_IDLE_OPTS=\"-i ${the_default_timeout} -a ${server_USB3_DISK_NAME2} -i ${the_sda_timeout} -l /var/log/hd-idle.log\"" "/etc/default/hd-idle" # insert as last line
fi
sudo cat "/etc/default/hd-idle"
sudo diff -U 10 "/etc/default/hd-idle.old" "/etc/default/hd-idle"
set +x
echo ""
echo "# Restart the hd-idle service to engage the updated config"
echo ""
set -x
sudo systemctl restart hd-idle
#sudo service hd-idle restart
sleep 5s
sudo cat /var/log/hd-idle.log
set +x
echo ""
echo "# Finished installation of hd-idle so that external USB3 disks spin dowwn when idle and not wear out quickly."
echo ""
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
echo "################################################################################################################################"
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "################################################################################################################################"
echo ""
echo "# Install NFS and create the file shares"
echo ""
read -p "# Press Enter to continue."
echo ""
# https://magpi.raspberrypi.org/articles/raspberry-pi-samba-file-server
# https://pimylifeup.com/raspberry-pi-samba/
nfs_export_top="/NFS-shares"
nfs_export_full="${nfs_export_top}/mp4library"
nfs_export_full2="${nfs_export_top}/mp4library2"
#
echo ""
echo "# Un-Install any previous NFS install ... no, just stop it instead."
echo ""
set -x
#sudo umount -f "${nfs_export_full}"
cd ~/Desktop
sudo systemctl stop nfs-kernel-server
sleep 3s
# Purge seems to cause it to fail on the subsequent re-install, so let's not purge.
#sudo apt purge -y nfs-common
#sudo apt purge -y nfs-kernel-server 
#sudo apt autoremove -y
set +x
echo ""
#sudo rm -fv "/etc/exports"
#sudo rm -fv "/etc/default/nfs-kernel-server"
#sudo rm -fv "/etc/idmapd.conf"
# do not rm the next 2 items, as it may accidentally wipe all of our media files !!!
#sudo rm -fvR "${nfs_export_full}"
#sudo rm -fvR "${nfs_export_top}"
echo ""
echo "# Comment out any prior NFS mount points in '/etc/fstab'"
echo ""
set -x
sudo rm -fv "/etc/fstab.pre-nfs.old"
sudo sed -i "s;${server_root_folder} ${nfs_export_full};#${server_root_folder} ${nfs_export_full};g" "/etc/fstab"
if [ "${SecondaryDisk}" = "y" ]; then
	sudo sed -i "s;${server_root_folder2} ${nfs_export_full2};#${server_root_folder2} ${nfs_export_full2};g" "/etc/fstab"
fi
set +x
echo ""
echo "# If modifying file '/etc/fstab' did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
##
echo ""
echo "# Install NFS then stop it again immediately."
echo ""
set -x
sudo apt install -y nfs-kernel-server 
sudo apt install -y nfs-common
sleep 3s
sudo systemctl stop nfs-kernel-server
sleep 3s
set +x
echo "# First check that uid=1000 and gid=1000 match the user pi "
echo ""
pi_uid="$(id -r -u pi)"
pi_gid="$(id -r -g pi)"
echo "uid=$(id -r -u pi) gid=$(id -r -g pi)" 
echo ""
echo "# Create the mount folders "
echo ""
set -x
cd ~/Desktop
sudo mkdir -p "${nfs_export_full}"
sudo chmod -c a=rwx -R "${nfs_export_top}"
sudo chmod -c a=rwx -R "${nfs_export_full}"
if [ "${SecondaryDisk}" = "y" ]; then
	sudo mkdir -p "${nfs_export_full2}"
	sudo chmod -c a=rwx -R "${nfs_export_full2}"
fi
# sudo mount -v --bind  "existing-folder-tree" "new-mount-point-folder"
id -u pi
id -g pi
# do not umount nfs_export_full as it dismounts the underpinning volume and causes things to crash 
#sudo umount -f "${nfs_export_full}" 
#sudo mount -v -a
set +x
echo ""
echo "# If creating the mount folders did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
##
echo ""
echo "# Mount the new shares"
echo ""
set -x
sudo df -h
sudo mount -v --bind "${server_root_folder}" "${nfs_export_full}" --options defaults,nofail,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=$(id -r -u pi),gid=$(id -r -g pi),noatime,nodiratime,x-systemd.device-timeout=120
ls -al "${server_root_folder}" 
ls -al "${nfs_export_full}" 
if [ "${SecondaryDisk}" = "y" ]; then
	sudo mount -v --bind "${server_root_folder2}" "${nfs_export_full2}" --options defaults,nofail,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=$(id -r -u pi),gid=$(id -r -g pi),noatime,nodiratime,x-systemd.device-timeout=120
	ls -al "${server_root_folder2}" 
	ls -al "${nfs_export_full2}" 
fi
set +x
echo ""
set -x
sudo df -h
sudo blkid
set +x
echo ""
echo "# If Mount the new shares did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
##
echo ""
echo "# Now add lines to file '/etc/fstab' so that the NFS shares are mounted the same way every time"
echo ""
set -x
sudo cp -fv "/etc/fstab" "/etc/fstab.pre-nfs.old"
sudo sed -i   "s;${server_root_folder} ${nfs_export_full};#${server_root_folder} ${nfs_export_full};g" "/etc/fstab"
sudo sed -i   "s;##;#;g" "/etc/fstab"
sudo sed -i "$ a ${server_root_folder} ${nfs_export_full} none bind,defaults,nofail,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=$(id -r -u pi),gid=$(id -r -g pi),noatime,nodiratime,x-systemd.device-timeout=120 0 0" "/etc/fstab"
if [ "${SecondaryDisk}" = "y" ]; then
	sudo sed -i   "s;${server_root_folder2} ${nfs_export_full2};#${server_root_folder2} ${nfs_export_full2};g" "/etc/fstab"
	sudo sed -i "$ a ${server_root_folder2} ${nfs_export_full2} none bind,defaults,nofail,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=$(id -r -u pi),gid=$(id -r -g pi),noatime,nodiratime,x-systemd.device-timeout=120 0 0" "/etc/fstab"
fi
set +x
echo ""
set -x
sudo cat "/etc/fstab"
sudo diff -U 10 "/etc/fstab.pre-nfs.old" "/etc/fstab" 
set +x
echo ""
echo "# If adding the lines to '/etc/fstab' did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
##
echo ""
echo "# Now add lines to file '/etc/exports' which definine the NFS shares"
echo ""
# note: id 1000 is user pi and group pi
set -x
sudo cp -fv "/etc/exports" "/etc/exports.old"
#... start comment out prior entries
sudo sed -i "s;${nfs_export_top} ${server_ip}/24;#${nfs_export_top} ${server_ip}/24;g" "/etc/exports"
sudo sed -i "s;${nfs_export_top} 127.0.0.1;#${nfs_export_top}127.0.0.1;g" "/etc/exports"
sudo sed -i "s;${nfs_export_full} ${server_ip}/24;#${nfs_export_full} ${server_ip}/24;g" "/etc/exports"
sudo sed -i "s;${nfs_export_full} 127.0.0.1;#${nfs_export_full} 127.0.0.1;g" "/etc/exports"
if [ "${SecondaryDisk}" = "y" ]; then
	sudo sed -i "s;${nfs_export_full2} ${server_ip}/24;#${nfs_export_full} ${server_ip}/24;g" "/etc/exports"
	sudo sed -i "s;${nfs_export_full2} 127.0.0.1;#${nfs_export_full} 127.0.0.1;g" "/etc/exports"
fi
#... end comment out prior entries
#... start add entries for the local LAN IP range
#sudo sed -i "$ a ${nfs_export_top} ${server_ip}/24(rw,insecure,sync,no_subtree_check,all_squash,crossmnt,fsid=0,root_squash,anonuid=$(id -r -u pi),anongid=$(id -r -g pi))" "/etc/exports"
sudo sed -i "$ a ${nfs_export_full} ${server_ip}/24(rw,insecure,sync,no_subtree_check,all_squash,crossmnt,anonuid=$(id -r -u pi),anongid=$(id -r -g pi))" "/etc/exports"
if [ "${SecondaryDisk}" = "y" ]; then
	sudo sed -i "$ a ${nfs_export_full2} ${server_ip}/24(rw,insecure,sync,no_subtree_check,all_squash,crossmnt,anonuid=$(id -r -u pi),anongid=$(id -r -g pi))" "/etc/exports"
fi
#... end add entries for the local LAN IP range
#... start add entries for localhost 127.0.0.1
#sudo sed -i "$ a ${nfs_export_top} 127.0.0.1(rw,insecure,sync,no_subtree_check,all_squash,crossmnt,fsid=0,root_squash,anonuid=$(id -r -u pi),anongid=$(id -r -g pi))" "/etc/exports"
sudo sed -i "$ a ${nfs_export_full} 127.0.0.1(rw,insecure,sync,no_subtree_check,all_squash,crossmnt,anonuid=$(id -r -u pi),anongid=$(id -r -g pi))" "/etc/exports"
if [ "${SecondaryDisk}" = "y" ]; then
	sudo sed -i "$ a ${nfs_export_full2} 127.0.0.1(rw,insecure,sync,no_subtree_check,all_squash,crossmnt,anonuid=$(id -r -u pi),anongid=$(id -r -g pi))" "/etc/exports"
fi
#... end add entries for localhost 127.0.0.1
sudo diff -U 10 "/etc/exports.old" "/etc/exports"
sudo cat "/etc/exports"
set +x
echo ""
echo "# If adding the lines to '/etc/exports' did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
##
echo ""
echo "# Now modify file '/etc/default/nfs-kernel-server' to change a paramter"
echo ""
#then check
# The only important option in /etc/default/nfs-kernel-server for now is NEED_SVCGSSD. 
# It is set to "no" by default, which is fine, because we are not activating NFSv4 security this time.
echo ""
set -x
sudo sed -i 's;NEED_SVCGSSD="";NEED_SVCGSSD="no";g' "/etc/default/nfs-kernel-server"
set +x
echo "Check /etc/default/nfs-kernel-server has parameter:"
echo 'NEED_SVCGSSD="no"'
echo ""
set -x
cat "/etc/default/nfs-kernel-server"
set +x
echo ""
echo "# If modifying file '/etc/default/nfs-kernel-server' did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
##
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
cat "/etc/idmapd.conf"
set +x
echo ""
echo "# If '/etc/idmapd.conf' did no have those 3 lines, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
##
echo ""
echo "# Now export the definitions to make them available"
echo ""
set -x
sudo exportfs -rav
sudo systemctl stop nfs-kernel-server
sleep 3s
sudo systemctl restart nfs-kernel-server
sleep 3s
set +x
echo ""
echo "# If the exportfs did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
##
echo ""
echo "# Now list the content of the shexport the definitions to make them available"
echo ""
set -x
ls -al "${server_root_folder}" 
ls -al "${nfs_export_full}" 
if [ "${SecondaryDisk}" = "y" ]; then
	ls -al "${server_root_folder2}" 
	ls -al "${nfs_export_full2}" 
fi
set +x
echo ""
echo "# If the listing did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
##
echo ""
echo "Now cleanup ..."
echo ""
set -x
sudo umount -f "/tmp-NFS-mountpoint"
sudo mkdir -p "/tmp-NFS-mountpoint"
sudo chmod -c a=rwx -R "/tmp-NFS-mountpoint"
#sudo ls -al "/tmp-NFS-mountpoint"
sudo mount -v -t nfs ${server_ip}:/${nfs_export_full} "/tmp-NFS-mountpoint"
sudo ls -al "/tmp-NFS-mountpoint/"
sudo umount -f "/tmp-NFS-mountpoint"
if [ "${SecondaryDisk}" = "y" ]; then
	sudo umount -f "/tmp-NFS-mountpoint2"
	sudo mkdir -p "/tmp-NFS-mountpoint2"
	sudo chmod -c a=rwx -R "/tmp-NFS-mountpoint2"
	#sudo ls -al "/tmp-NFS-mountpoint2"
	sudo mount -v -t nfs ${server_ip}:/${nfs_export_full2} "/tmp-NFS-mountpoint2"
	sudo ls -al "/tmp-NFS-mountpoint2/"
	sudo umount -f "/tmp-NFS-mountpoint2"
fi
#sudo rm -vf "/tmp-NFS-mountpoint"
# do NOT remove it as it may accidentally wipe the mounted drive !!!
set +x
#
echo "# If the cleanup did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
echo "################################################################################################################################"
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "################################################################################################################################"
echo ""
echo "# Install SAMBA and create the file shares"
read -p "# Press Enter to continue."
echo ""



echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------





#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "# Get ready for minidlna. "
echo "# Increase system max_user_watches to avoid this error:"
echo "# WARNING: Inotify max_user_watches [8192] is low or close to the number of used watches [2] and I do not have permission to increase this limit.  Please do so manually by writing a higher value into /proc/sys/fs/inotify/max_user_watches."
set -x
# sudo sed -i.bak "s;8182;32768;g" "/proc/sys/fs/inotify/max_user_watches" # this fails with no permissions
sudo cat /proc/sys/fs/inotify/max_user_watches
# set a new temporary limit with:
#sudo sysctl fs.inotify.max_user_watches=131072
sudo sysctl fs.inotify.max_user_watches=262144
sudo sysctl -p
# set a new permanent limit with:
sudo sed -i.bak "s;fs.inotify.max_user_watches=;#fs.inotify.max_user_watches=;g" "/etc/sysctl.conf"
#echo fs.inotify.max_user_watches=131072 | sudo tee -a "/etc/sysctl.conf"
echo fs.inotify.max_user_watches=262144 | sudo tee -a "/etc/sysctl.conf"
sudo sysctl -p
set +x
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "# Install miniDLNA and configure it"
read -p "# Press Enter to continue."
echo ""
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------





#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "# Install proFTPd set server and ocnfigure it"
read -p "# Press Enter to continue."
echo ""
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------



echo ""
echo "# Please Reboot the Pi4 now for the updated settings to take effect"
echo "# Please Reboot the Pi4 now for the updated settings to take effect"
echo "# Please Reboot the Pi4 now for the updated settings to take effect"
echo "# Please Reboot the Pi4 now for the updated settings to take effect"
echo ""

exit

#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i.bak s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
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
sudo dhclient -4
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
echo "# Instructions:"
echo "# The upcoming commands should yield something a bit like this"
echo '# /dev/mmcblk0p1: LABEL_FATBOOT="boot" LABEL="boot" UUID="69D5-9B27" TYPE="vfat" PARTUUID="d9b3f436-01"'
echo '# /dev/mmcblk0p2: LABEL="rootfs" UUID="24eaa08b-10f2-49e0-8283-359f7eb1a0b6" TYPE="ext4" PARTUUID="d9b3f436-02"'
echo '# /dev/sda2: LABEL="5TB-mp4library" UUID="F8ACDEBBACDE741A" TYPE="ntfs" PTTYPE="atari" PARTLABEL="Basic data partition" PARTUUID="6cc8d3fb-6942-4b4b-a7b1-c31d864accef"'
echo '# /dev/mmcblk0: PTUUID="d9b3f436" PTTYPE="dos"'
echo '# /dev/sda1: PARTLABEL="Microsoft reserved partition" PARTUUID="62ac9e1a-a82b-4df7-92b9-19ffc689d80b"'
echo "# Look for the Disk Label ... in the above case the UUID is F8ACDEBBACDE741A "
echo "# ... copy and paste the UUID string somewhere as we must use it later"
echo "# Then look for its physical mount point ... in this case it is /dev/sda2"
echo "# ... copy and paste the string somewhere as we must use it later"
echo "# With a second USB3 drive, both these would be obvious as well ... also copy and paste these strings somewhere as we must use them later"
#echo ""
#read -p "# Press Enter to see the values on this Pi4 continue."
echo ""
echo "Settings for this Pi4:"
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
# Ask for and setup default settings and try to remember them. Yes there's a ". " at the start of the line".
sdname=./setupNAS_ask_defaults.sh
echo . "${sdname}"
set -x
. "${sdname}"
set +x
echo ""
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
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
sudo rm -f ./tmp.tmp
sudo sed -i.bak "/boot_delay/d" "/boot/config.txt"
echo "boot_delay=30" > ./tmp.tmp
sudo cat /boot/config.txt >> ./tmp.tmp
sudo cp -fv ./tmp.tmp /boot/config.txt
sudo rm -f ./tmp.tmp
set +x
echo ""
set -x
sudo diff -U 10 "/boot/config.txt.old" "/boot/config.txt"
set +x
echo ""
set -x
sudo cat "/boot/config.txt"
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
echo "# Re-Update the Rasbperry Pi4 Operating System with the latest patches, given we now have more Sources."
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
sudo ls -al "/lib/modules/$(uname -r)/kernel/fs/"
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
echo "# Install 'hd-idle' so that external USB3 disks spin down when idle and not wear out quickly."
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
cd ~/Desktop
wget http://sourceforge.net/projects/hd-idle/files/hd-idle-1.05.tgz
tar -xvf hd-idle-1.05.tgz
cd hd-idle
sudo dpkg-buildpackage -rfakeroot
sudo dpkg -i ../hd-idle_*.deb
cd ..
sudo dpkg -l hd-idle
cd ~/Desktop
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
sudo id -u pi
sudo id -g pi
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
sudo ls -al "${server_root_folder}" 
sudo ls -al "${nfs_export_full}" 
if [ "${SecondaryDisk}" = "y" ]; then
	sudo mount -v --bind "${server_root_folder2}" "${nfs_export_full2}" --options defaults,nofail,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=$(id -r -u pi),gid=$(id -r -g pi),noatime,nodiratime,x-systemd.device-timeout=120
	sudo ls -al "${server_root_folder2}" 
	sudo ls -al "${nfs_export_full2}" 
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
sudo cat "/etc/default/nfs-kernel-server"
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
sudo cat "/etc/idmapd.conf"
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
sudo ls -al "${server_root_folder}" 
sudo ls -al "${nfs_export_full}" 
if [ "${SecondaryDisk}" = "y" ]; then
	sudo ls -al "${server_root_folder2}" 
	sudo ls -al "${nfs_export_full2}" 
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
echo ""
echo "# If the cleanup did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
echo "################################################################################################################################"
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "################################################################################################################################"
echo ""
echo "# Install SAMBA and create the file shares"
echo ""
read -p "# Press Enter to continue."
echo ""
echo "# Un-Install any previous SAMBA install ..."
echo ""
set -x
#sudo systemctl stop smbd
sudo apt-get purge -y --allow-unauthenticated --allow-remove-essential winbind
sudo apt-get purge -y --allow-unauthenticated --allow-remove-essential samba-common
sudo apt-get purge -y --allow-unauthenticated --allow-remove-essential samba
sudo apt autoremove -y
sudo apt-get check -y samba
sudo rm -vf "/etc/samba/smb.conf"
sudo rm -vf "/etc/samba/smb.conf.old"
sudo rm -vfR "/etc/samba"
sudo rm -vfR "/var/lib/samba"
sudo rm -vfR "/usr/share/samba"
#sudo rm -vf "/etc/rc*.d/*samba" "/etc/init.d/samba"
sudo apt-get install -y --reinstall --fix-broken --fix-missing --allow-unauthenticated winbind
sudo apt-get install -y             --fix-broken --fix-missing --allow-unauthenticated samba
sudo apt-get install -y --reinstall --fix-broken --fix-missing --allow-unauthenticated samba
set +x
echo ""
echo "# If the Un-Install did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
##
echo ""
echo "# Create a SAMBA password."
echo ""
echo "# Before we start the server, you’ll want to set a Samba password. Enter you pi password."
echo "# Before we start the server, you’ll want to set a Samba password. Enter you pi password."
set -x
sudo smbpasswd -a pi
sudo smbpasswd -a root
set +x
echo ""
echo "# If the SAMBA password creation did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
##
echo ""
echo "# Use a modified SAMBA conf with all of the good stuff"
echo ""
set -x
cd ~/Desktop
sudo rm -vf "./smb.conf"
url="https://raw.githubusercontent.com/hydra3333/Pi4CC/master/setup_support_files/smb.conf"
curl -4 -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -H 'Cache-Control: max-age=0' "$url" --retry 50 -L --output "./smb.conf" --fail # -L means "allow redirection" or some odd :|
sudo cp -fv "./smb.conf"  "./smb.conf.old"
set +x
echo "Start Adding stuff to configuration file './smb.conf' ..."
echo "[${server_alias}]">>"./smb.conf"
echo "comment=Pi4CC ${server_alias} home">>"./smb.conf"
echo "#force group = users">>"./smb.conf"
echo "#guest only = Yes">>"./smb.conf"
echo "guest ok = Yes">>"./smb.conf"
echo "public = yes">>"./smb.conf"
echo "#valid users = @users">>"./smb.conf"
echo "path = ${server_root_folder}">>"./smb.conf"
echo "available = yes">>"./smb.conf"
echo "read only = no">>"./smb.conf"
echo "browsable = yes">>"./smb.conf"
echo "writeable = yes">>"./smb.conf"
echo "#create mask = 0777">>"./smb.conf"
echo "#directory mask = 0777">>"./smb.conf"
echo "force create mode = 1777">>"./smb.conf"
echo "force directory mode = 1777">>"./smb.conf"
echo "inherit permissions = yes">>"./smb.conf"
echo "# 2020.08.10">>"./smb.conf"
echo "allow insecure wide links = yes">>"./smb.conf"
echo "follow symlinks = yes">>"./smb.conf"
echo "wide links = yes">>"./smb.conf"
echo "">>"./smb.conf"
if [ "${SecondaryDisk}" = "y" ]; then
	echo "[${server_alias}2]">>"./smb.conf"
	echo "comment=Pi4CC ${server_alias}2 home">>"./smb.conf"
	echo "#force group = users">>"./smb.conf"
	echo "#guest only = Yes">>"./smb.conf"
	echo "guest ok = Yes">>"./smb.conf"
	echo "public = yes">>"./smb.conf"
	echo "#valid users = @users">>"./smb.conf"
	echo "path = ${server_root_folder2}">>"./smb.conf"
	echo "available = yes">>"./smb.conf"
	echo "read only = no">>"./smb.conf"
	echo "browsable = yes">>"./smb.conf"
	echo "writeable = yes">>"./smb.conf"
	echo "#create mask = 0777">>"./smb.conf"
	echo "#directory mask = 0777">>"./smb.conf"
	echo "force create mode = 1777">>"./smb.conf"
	echo "force directory mode = 1777">>"./smb.conf"
	echo "inherit permissions = yes">>"./smb.conf"
	echo "# 2020.08.10">>"./smb.conf"
	echo "allow insecure wide links = yes">>"./smb.conf"
	echo "follow symlinks = yes">>"./smb.conf"
	echo "wide links = yes">>"./smb.conf"
	echo "">>"./smb.conf"
fi
echo "Finished Adding stuff to file './smb.conf' ..."
set -x
sudo chmod -c a=rwx -R *
#sudo diff -U 10 "./smb.conf.old" "./smb.conf"
sudo rm -vf "/etc/samba/smb.conf.old"
sudo cp -vf "/etc/samba/smb.conf" "/etc/samba/smb.conf.old"
sudo cp -vf "./smb.conf" "/etc/samba/smb.conf"
sudo chmod -c a=rwx -R "/etc/samba"
sudo diff -U 10 "/etc/samba/smb.conf.old" "/etc/samba/smb.conf"
set +x
echo ""
echo "# If modifying the SAMBA conf did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
##
echo ""
echo "# Test that the samba config is OK"
echo "# ignore this: # rlimit_max: increasing rlimit_max (1024) to minimum Windows limit (16384) ..."
echo ""
set -x
sudo testparm
set +x
echo ""
echo "# If testparm did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
##
echo ""
echo "# Restart Samba service"
echo ""
set -x
sudo systemctl stop smbd
sudo systemctl restart smbd
#sudo service smbd restart
sleep 10s
set +x
echo ""
echo "# If service start did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
##
echo ""
echo "# List the new Sanba users (which can have different passwords to the Pi itself)"
echo ""
set -x
sudo pdbedit -L -v
set +x
echo ""
echo "# If service start did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
##
echo ""
echo "You can now access the defined shares from a Windows machine"
echo "or from an app that supports the SMB protocol"
echo "eg from Win10 PC in Windows Explorer use the IP address of ${server_name} like ... \\\\${server_ip}\\ "
set -x
sudo hostname
sudo hostname --fqdn
sudo hostname --all-ip-addresses
set +x
##
echo ""
echo "# If something did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
echo "################################################################################################################################"
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "################################################################################################################################"
echo ""
echo "# Install and configure minDLNA"
echo ""
# not strictly necessary to install, however it makes the server more "rounded" and accessible
# https://unixblogger.com/dlna-server-raspberry-pi-linux/
# https://www.youtube.com/watch?v=Vry0NpFjn5w
# https://www.deviceplus.com/how-tos/setting-up-raspberry-pi-as-a-home-media-server/
read -p "# Press Enter to continue."
echo ""
echo ""
echo "# Get ready for miniDLNA. "
echo "# Per https://wiki.debian.org/minidlna"
echo "# To avoid Inotify errors, Increase the number for the system :"
echo "# In /etc/sysctl.conf Add: 'fs.inotify.max_user_watches=65536' in a blank line by itself."
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
echo ""
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
##
echo ""
echo "# Un-Install any prior minDLNA"
echo ""
read -p "# Press Enter to continue."
echo ""
set -x
sudo apt purge minidlna -y
sudo apt autoremove -y
#sleep 3s
sudo rm -vfR "/etc/minidlna.conf"
sudo rm -vfR "/var/log/minidlna.log"
sudo rm -vfR "/run/minidlna"
sudo rm -vfR "${server_root_USBmountpoint}/minidlna"
set +x
echo ""
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
##
echo ""
echo "# Do the minidlna install and the stop the service so we can configure it"
echo ""
set -x
sudo apt install -y minidlna
sleep 3s
sudo systemctl stop minidlna
#sudo service minidlna stop
sleep 5s
set +x
echo ""
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
##
echo ""
echo "# Add Groups, then Create a folder for minidlna logs and db - place the folder in the root of the USB3 drive"
echo ""
set -x
#sudo usermod -a -G www-data minidlna
sudo usermod -a -G pi minidlna
sudo usermod -a -G minidlna pi
sudo usermod -a -G minidlna root
sudo mkdir -p "${server_root_USBmountpoint}/minidlna"
sudo chmod -c a=rwx -R "${server_root_USBmountpoint}/minidlna"
sudo chown -c -R pi:minidlna "${server_root_USBmountpoint}/minidlna"
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
#sudo cat "/var/log/minidlna.log"
#sudo rm -vfR "/var/log/minidlna.log"
set +x
echo ""
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
##
echo ""
echo "# Change miniDLNA config settings"
echo ""
set -x
log_dir=${server_root_USBmountpoint}/minidlna
db_dir=${server_root_USBmountpoint}/minidlna
sh_dir=${server_root_USBmountpoint}/minidlna
sudo cp -fv "/etc/minidlna.conf" "/etc/minidlna.conf.old"
sudo sed -i "s;#user=minidlna;#user=minidlna\n#user=pi;g" "/etc/minidlna.conf"
sudo sed -i "s;media_dir=/var/lib/minidlna;#media_dir=/var/lib/minidlna\nmedia_dir=PV,${server_root_folder};g" "/etc/minidlna.conf"
sudo sed -i "s;#db_dir=/var/cache/minidlna;#db_dir=/var/cache/minidlna\ndb_dir=${db_dir};g" "/etc/minidlna.conf"
sudo sed -i "s;#log_dir=/var/log;#log_dir=/var/log\nlog_dir=${log_dir};g" "/etc/minidlna.conf"
sudo sed -i "s;#friendly_name=;#friendly_name=\nfriendly_name=${server_name}-minidlna;g" "/etc/minidlna.conf"
sudo sed -i "s;#inotify=yes;#inotify=yes\ninotify=yes;g" "/etc/minidlna.conf"
sudo sed -i "s;#strict_dlna=no;#strict_dlna=no\nstrict_dlna=yes;g" "/etc/minidlna.conf"
sudo sed -i "s;#notify_interval=895;#notify_interval=895\nnotify_interval=900;g" "/etc/minidlna.conf"
sudo sed -i "s;#max_connections=50;#max_connections=50\nmax_connections=6;g" "/etc/minidlna.conf"
sudo sed -i "s;#log_level=general,artwork,database,inotify,scanner,metadata,http,ssdp,tivo=warn;#log_level=general,artwork,database,inotify,scanner,metadata,http,ssdp,tivo=warn\nlog_level=artwork,database,general,http,inotify,metadata,scanner,ssdp,tivo=info;g" "/etc/minidlna.conf"
sudo sed -i "s;#wide_links=no;wide_links=yes;g" "/etc/minidlna.conf"
sudo diff -U 10 "/etc/minidlna.conf.old" "/etc/minidlna.conf"
set +x
echo ""
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
##
echo ""
echo "# Reconfigure miniDLNA."
echo "# Also force a re-scan at 4:00 am every night using crontab"
echo ""
# https://sourceforge.net/p/minidlna/discussion/879956/thread/41ae22d6/#4bf3
# To restart the service
#sudo service minidlna restart
set -x
sudo systemctl stop minidlna
#sudo service minidlna stop
set +x
Restart_sh_file=~/Desktop/minidlna_restart_refresh.sh
sh_file=${sh_dir}/minidlna_refresh.sh
log_file=${log_dir}/minidlna_refresh.log
main_log_dir=${log_dir}/minidlna.log
set -x
sudo rm -vf "${log_file}"
sudo touch "${log_file}"
sudo rm -vf "${sh_file}"
set +x
echo "#!/bin/bash" >> "${sh_file}"
echo "set -x" >> "${sh_file}"
echo "sudo systemctl stop minidlna" >> "${sh_file}"
echo "#sudo service minidlna stop" >> "${sh_file}"
echo "sleep 10s" >> "${sh_file}"
echo "sudo systemctl start minidlna" >> "${sh_file}"
echo "#sudo service minidlna start" >> "${sh_file}"
echo "sleep 10s" >> "${sh_file}"
echo "sudo systemctl reload-or-restart minidlna" >> "${sh_file}"
echo "#sudo service minidlna force-reload # same as systemctl reload-or-restart" >> "${sh_file}"
echo "echo 'Wait 15 minutes for minidlna to index media files'" >> "${sh_file}"
echo "echo 'For progress do: cat ${main_log_dir}'" >> "${sh_file}"
echo "sleep 900s" >> "${sh_file}"
echo "set +x" >> "${sh_file}"
set -x
sudo rm -vf "${Restart_sh_file}"
sudo cp -vf "${sh_file}" "${Restart_sh_file}"
sudo chmod -c a=rwx ~/Desktop/*.sh
set +x
echo "#" >> "${Restart_sh_file}"
echo "#${sh_file}" >> "${Restart_sh_file}"
echo "#" >> "${Restart_sh_file}"
echo "cat ${log_file}" >> "${Restart_sh_file}"
echo "#" >> "${Restart_sh_file}"
echo "cat ${main_log_dir}" >> "${Restart_sh_file}"
echo "#" >> "${Restart_sh_file}"
# https://stackoverflow.com/questions/610839/how-can-i-programmatically-create-a-new-cron-job
echo ""
echo "Adding the 4:00am nightly crontab job to re-index minidlna"
echo ""
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
set -x
sudo crontab -l # before
set +x
echo ""
( crontab -l ; echo "0 4 * * * ${sh_file} 2>&1 >> ${log_file}" ) 2>&1 | sed "s/no crontab for $(whoami)//g" | sort - | uniq - | crontab -
echo ""
set -x
sudo crontab -l # after
sudo grep CRON /var/log/syslog
set +x
echo ""
echo "# If the crontab did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
##
echo ""
echo "# Start miniDLNA."
echo ""
sudo ls -al "/run/minidlna"
sudo systemctl start minidlna
#sudo service minidlna start
sleep 10s
echo "#"
echo "# The minidlna service comes with a small webinterface. "
echo "# This webinterface is just for informational purposes. "
echo "# You will not be able to configure anything here. "
echo "# However, it gives you a nice and short information screen how many files have been found by minidlna. "
echo "# minidlna comes with it’s own webserver integrated. "
echo "# This means that no additional webserver is needed in order to use the webinterface."
echo "# To access the webinterface, open your browser of choice and enter "
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
echo "# If the start and curl did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
##
echo ""
sudo ls -al "/run/minidlna"
sudo cat ${log_dir}/minidlna.log
sudo cat "/var/log/minidlna.log"
echo ""
echo "# Force a re-load of miniDLNA to ensure it starts re-looking for new files."
echo ""
sudo systemctl reload-or-restart minidlna
#sudo service minidlna force-reload # same as systemctl reload-or-restart
sleep 10s
sudo cat ${log_dir}/minidlna.log
sudo cat "/var/log/minidlna.log"
set +x
echo ""
echo "# If something did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
echo "################################################################################################################################"
#-------------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------------------------------------
echo ""
echo "################################################################################################################################"
echo ""
echo "# Install proFTPd set server and configure it. It is connectable from filezilla"
echo ""
read -p "# Press Enter to continue."
echo ""
echo "# Un-Install then Install any prior proFTPd"
echo ""
set -x
cd ~/Desktop
sudo kill -TERM `cat /run/proftpd.pid`
sudo rm -fv "/etc/shutmsg"
sudo apt purge -y proftpd proftpd-basic proftpd-mod-case proftpd-doc 
sudo chmod -c a=rwx -R "/etc/proftpd/proftpd.conf"
sudo rm -vf "/etc/proftpd/proftpd.conf" "/etc/proftpd/proftpd.conf.old"
sudo apt install -y proftpd proftpd-mod-case proftpd-doc 
sudo cat /var/log/proftpd/proftpd.log
set +x
echo ""
echo "# If something did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
##
echo ""
echo "# Configure proFTPd"
echo ""
# https://htmlpreview.github.io/?https://github.com/Castaglia/proftpd-mod_case/blob/master/mod_case.html
# Use directives
#  CaseIgnore on
#  LoadModule mod_case.c
# to enable case-insensitivity for all FTP commands handled by mod_case
# http://www.proftpd.org/docs/howto/ServerType.html
# http://www.proftpd.org/docs/howto/Stopping.html
# update the conf file
set -x
# http://www.proftpd.org/docs/howto/Stopping.html
# deny incoming connections - does not stop the ftp server
sudo ftpshut -l 0 -d 0 now
# now kill the daemon
sudo kill -TERM `cat /run/proftpd.pid`
#
sudo rm -fv "/etc/proftpd/proftpd.conf.old"
sudo cp -fv "/etc/proftpd/proftpd.conf" "/etc/proftpd/proftpd.conf.old" 
rm -fv "./tmp.tmp"
cat<<EOF >"./tmp.tmp"
# Case Sensitive module at top
LoadModule mod_case.c
<IfModule mod_case.c>
CaseIgnore on
</IfModule>
EOF
sudo cat "/etc/proftpd/proftpd.conf">>"./tmp.tmp"
#
sudo sed -i "s;ServerName\t\t\t\"Debian\";ServerName\t\t\t\"Pi4CC\";g" "./tmp.tmp"
sudo sed -i "s;DisplayLogin;#DisplayLogin;g" "./tmp.tmp"
sudo sed -i "s;DisplayChdir;#DisplayChdir;g" "./tmp.tmp"
sudo sed -i "s;# RequireValidShell\t\toff;RequireValidShell\t\toff;g" "./tmp.tmp"
sudo sed -i "s;User\t\t\t\tproftpd;User\t\t\t\tpi;g" "./tmp.tmp"
sudo sed -i "s;Group\t\t\t\tnogroup;Group\t\t\t\tpi;g" "./tmp.tmp"
sudo sed -i "s;Group\t\t\t\tpi;Group\t\t\t\tpi\nDefaultRoot \~ \!pi,\!www-data;g" "./tmp.tmp"
sudo sed -i "s;Umask\t\t\t\t022  022;Umask\t\t\t\t000  000;g" "./tmp.tmp"
#"/boot_delay/d"
sudo sed -i "/# Include other custom configuration files/d" "./tmp.tmp"
sudo sed -i "/Include \/etc\/proftpd\/conf.d\//d" "./tmp.tmp"
#cat<<EOF >>"./tmp.tmp"
#<Anonymous ~pi>
#User pi
#Group pi
#DefaultRoot ~ !pi,!www-data
#UserAlias anonymous pi
#RequireValidShell off
#MaxClients 30
#Umask 000 000
#<Directory *>
#Umask 000 000
#<Limit WRITE>
#AllowAll
#</Limit>
#</Directory>
#</Anonymous>
# Include other custom configuration files
#Include /etc/proftpd/conf.d/
#EOF
#sudo cat "./tmp.tmp"
#
sudo cp -fv "./tmp.tmp" "/etc/proftpd/proftpd.conf"
sudo rm -f "./tmp.tmp"
sudo ls -al "/etc/proftpd/proftpd.conf.old" "/etc/proftpd/proftpd.conf"
sudo diff -U 10 "/etc/proftpd/proftpd.conf.old" "/etc/proftpd/proftpd.conf"
# re-enable server
sudo kill -TERM `cat /run/proftpd.pid`
sudo rm -fv "/etc/shutmsg"
sudo proftpd
#
sudo proftpd -t -d5
#sudo proftpd -vv
#sudo proftpd --list 
set +x
echo ""
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
echo "################################################################################################################################"
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------

echo ""
set -x
cd ~/Desktop
sudo chmod -c a=rwx -R *
set +x
#
echo ""
echo "# Please Reboot the Pi4 now for the updated settings to take effect"
echo "# Please Reboot the Pi4 now for the updated settings to take effect"
echo "# Please Reboot the Pi4 now for the updated settings to take effect"
echo "# Please Reboot the Pi4 now for the updated settings to take effect"
echo ""

exit

#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i.bak s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo "# This is now the x64 version for Raspberry Pi OS x64 - and ONLY the x64 version"
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
set -x
cd ~/Desktop
set +x
while true; do
	read -p "Have you completed the pre-Install instructions per README.md on this GIT ? [y/n]? " yn
	case $yn in
		[Yy]* ) OK=y; break;;
		[Nn]* ) OK=n; break;;
		* ) echo "Please answer y or n only.";;
	esac
done
if [[ "${OK}" = "n" ]]; then
	echo ""
	echo ""
	echo "You MUST first complete the pre-Install instructions per README.md on this GIT"
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
echo ""
echo "# Re-Update the Rasbperry Pi4 Operating System with the latest patches, given we now have more Sources."
echo ""
set -x
sudo apt update -y
sudo apt full-upgrade -y
set +x
echo ""
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Add 'plugdev' right to user pi so that it has no trouble with mounting USB3 external disk(s)."
echo ""
set -x
sudo usermod -a -G plugdev pi
set +x
echo ""
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Install a remote-printing feature so we can print from the Pi via the Windows 10 PC."
echo ""
set -x
sudo apt install -y cups
set +x
echo ""
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Install https for distros, although it is not strictly needed"
echo ""
set -x
sudo apt install -y apt-transport-https
set +x
echo ""
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Install mergerfs which we need to logically merge folders together for presentation eg via NFS"
echo ""
set -x
sudo apt install -y mergerfs
set +x
echo ""
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Install the tool which can be used to turn EOL inside text files from windows type to unix type"
echo ""
set -x
sudo apt install -y dos2unix
set +x
echo ""
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Install the curl and wget tools to download support files if required"
echo ""
set -x
sudo apt install -y curl
sudo apt install -y wget
set +x
echo "# If that did not work, control-C then fix any issues, then re-start this script."
echo ""
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
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
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
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
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "OK, check some settings on the Pi4"
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
echo "# Just for kicks, see what filesystems are supported by the Pi4 (NTFS should be listed)"
echo ""
set -x
sudo ls -al "/lib/modules/$(uname -r)/kernel/fs/"
set +x
echo ""
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Find and note EXACTLY the correct UUID= string and physical mount point string for the USB3 external disk(s)"
echo ""
#echo "# Instructions:"
#echo "# The upcoming commands should yield something a bit like this"
#echo '# /dev/mmcblk0p1: LABEL_FATBOOT="boot" LABEL="boot" UUID="69D5-9B27" TYPE="vfat" PARTUUID="d9b3f436-01"'
#echo '# /dev/mmcblk0p2: LABEL="rootfs" UUID="24eaa08b-10f2-49e0-8283-359f7eb1a0b6" TYPE="ext4" PARTUUID="d9b3f436-02"'
#echo '# /dev/sda2: LABEL="5TB-mp4library" UUID="F8ACDEBBACDE741A" TYPE="ntfs" PTTYPE="atari" PARTLABEL="Basic data partition" PARTUUID="6cc8d3fb-6942-4b4b-a7b1-c31d864accef"'
#echo '# /dev/mmcblk0: PTUUID="d9b3f436" PTTYPE="dos"'
#echo '# /dev/sda1: PARTLABEL="Microsoft reserved partition" PARTUUID="62ac9e1a-a82b-4df7-92b9-19ffc689d80b"'
#echo "# Look for the Disk Label ... in the above case the UUID is F8ACDEBBACDE741A "
#echo "# ... copy and paste the UUID string somewhere as we must use it later"
#echo "# Then look for its physical mount point ... in this case it is /dev/sda2"
#echo "# ... copy and paste the string somewhere as we must use it later"
#echo "# With a second USB3 drive, both these would be obvious as well ... also copy and paste these strings somewhere as we must use them later"
#echo ""
#read -p "# Press Enter to see the values on this Pi4 continue."
echo ""
set -x
sudo df
sudo blkid 
set +x
echo ""
#
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
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Update /etc/apt/sources.list so that all standard repositories for x64 o/s updates are allowed."
echo ""
# x32:
#sudo sed -i.bak "s/# deb/deb/g" "/etc/apt/sources.list"
# x64:
set -x
sudo sed -i.bak "s/#deb/deb/g" "/etc/apt/sources.list"
cat "/etc/apt/sources.list"
set +x
echo ""
#
### echo "#-------------------------------------------------------------------------------------------------------------------------------------"
### echo ""
### echo "# Add 30 seconds for the USB3 drive to spin up during startup."
### echo ""
### # Add the line at the top. # per https://www.raspberrypi.org/documentation/configuration/config-txt/boot.md"
### echo ""
### echo "# Adding a line 'boot_delay=30' at the top of '/boot/config.txt'"
### echo ""
### ##sudo sed -i.bak "1 i boot_delay=30" "/boot/config.txt" # doesn't work if the file has no line 1
### set -x
### sudo cp -fv "/boot/config.txt" "/boot/config.txt.old"
### sudo rm -f ./tmp.tmp
### sudo sed -i.bak "/boot_delay/d" "/boot/config.txt"
### echo "boot_delay=30" > ./tmp.tmp
### sudo cat /boot/config.txt >> ./tmp.tmp
### sudo cp -fv ./tmp.tmp /boot/config.txt
### sudo rm -f ./tmp.tmp
### set +x
### echo ""
### set -x
### sudo diff -U 10 "/boot/config.txt.old" "/boot/config.txt"
### set +x
### echo ""
### set -x
### sudo cat "/boot/config.txt"
### set +x
### echo ""
### echo "# If that did not work, control-C then fix any issues, then re-start this script."
### read -p "# Otherwise - Press Enter to continue."
### echo ""
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Create mount point folder(s) for the USB3 drive(s), which we'll use in a minute."
echo ""
set -x
sudo mkdir -pv ${USB3_mountpoint_1}
sudo chmod -c a=rwx -R ${USB3_mountpoint_1}
if [[ "${SecondDisk}" = "y" ]]; then
	sudo mkdir -pv ${USB3_mountpoint_2}
	sudo chmod -c a=rwx -R ${USB3_mountpoint_2}
fi
sudo mkdir -pv ${mergerfs_mountpoint}
sudo chmod -c a=rwx -R ${mergerfs_mountpoint}
set +x
echo ""
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Now we add a line to file '/etc/fstab' so that USB3 drives are installed the same every time"
echo "# Remember, always be consistent and plugin "
echo "#    1. the FIRST   USB3 drive into the bottom USB3 socket"
echo "#    2. the SECOND  USB3 drive into the top    USB3 socket (if we have a second drive)"
echo "# https://wiki.debian.org/fstab"
echo ""
set -x
sudo cp -fv "/etc/fstab" "/etc/fstab.old"
# put a "#" at the start of all lines containing this string: ntfs defaults,auto
sudo sed -i.bak "/ntfs defaults,auto/s/^/#/" "/etc/fstab"
#	"/ntfs defaults,auto/" matches a line with "ntfs defaults,auto"
#	s perform a substitution on the lines matched above (notice no "g" at the end of the "s" due to aforementioned line matching)
#	The substitution will insert a pound character (#) at the beginning of the line (^)
#	old subst fails with too many substitutes if server_USB3_DEVICE_UUID2 is blank : sudo sed -i.bak "s/UUID=${server_USB3_DEVICE_UUID}/#UUID=${server_USB3_DEVICE_UUID}/g" "/etc/fstab"
sudo sed -i.bak "s/UUID=${USB3_DEVICE_UUID_1}/#UUID=${USB3_DEVICE_UUID_1}/g" "/etc/fstab"
sudo sed -i.bak "$ a UUID=${USB3_DEVICE_UUID_1} ${USB3_mountpoint_1} ntfs defaults,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=$(id -r -u pi),gid=$(id -r -g pi),noatime,nodiratime,x-systemd.device-timeout=120 0 0" "/etc/fstab"
set +x
if [[ "${SecondDisk}" = "y" ]]; then
	set -x
	sudo sed -i.bak "s/UUID=${USB3_DEVICE_UUID_2}/#UUID=${USB3_DEVICE_UUID_2}/g" "/etc/fstab"
	sudo sed -i.bak "$ a UUID=${USB3_DEVICE_UUID_2} ${USB3_mountpoint_2} ntfs defaults,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=$(id -r -u pi),gid=$(id -r -g pi),noatime,nodiratime,x-systemd.device-timeout=120 0 0" "/etc/fstab"
	set +x
fi
echo "# Now we add a line to file '/etc/fstab' so that mergerfs drives are designated the same every time"
set -x
mergerfs_requires_1="x-systemd.requires=${USB3_mountpoint_1}"
if [[ "${SecondDisk}" = "y" ]]; then
	mergerfs_requires_2=",x-systemd.requires=${USB3_mountpoint_2}"
else
	mergerfs_requires_2=""
fi
# define disks which be mounted prior to mergerfs
mergerfs_requires="${mergerfs_requires_1}${mergerfs_requires_2}"
# comment out any existing mergerfs mountpoint in /etc/fstab
sudo sed -i.bak "s;.*${mergerfs_mountpoint};#&;g" "/etc/fstab"
# add a new mergerfs mount point defining the required folder(s) ... see 
# https://manpages.ubuntu.com/manpages/impish/man1/mergerfs.1.html
# https://github.com/trapexit/mergerfs
# https://forums.raspberrypi.com/viewtopic.php?p=2020660#p2020660
sudo sed -i.bak "$ a ${mergerfs_folders} ${mergerfs_mountpoint} fuse.mergerfs defaults,nofail,auto,owner,users,rw,exec,${mergerfs_requires},noatime,nonempty,allow_other,moveonenospc=true,use_ino,noforget,inodecalc=path-hash,nfsopenhack=all,threads=0,cache.files=partial,dropcacheonclose=true,category.create=epall,category.action=epall,category.search=epff,statfs=base,statfs_ignore=none,func.getattr=newest,fsname=mergerfs 0 0" "/etc/fstab"
set +x
# to do it manually see this example ...
#sudo mergerfs -o nonempty,allow_other,moveonenospc=true,use_ino,noforget,inodecalc=path-hash,nfsopenhack=all,threads=0,cache.files=partial,dropcacheonclose=true,category.create=epall,category.action=epall,category.search=epff,statfs=base,statfs_ignore=none,func.getattr=newest,fsname=mergerfs /mnt/mp4library1/mp4library1:/mnt/mp4library2/mp4library2 /mnt/mergerfs/mp4library
#ls -al /mnt/mp4library1/mp4library1
#ls -al /mnt/mp4library2/mp4library2
#ls -al /mnt/mergerfs/mp4library
#
set +x
echo ""
set -x
sudo diff -U 10 "/etc/fstab.old" "/etc/fstab" 
sudo cat "/etc/fstab"
set +x
echo ""
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "We have now completed PART 1 of the setup."
echo ""
echo "Now we will reboot the Pi4, so that the USB3 external disk(s) are recognisd by fstab and mounted correctly for you to execute 'setupNAS_part_2.sh'"
echo ""
read -p "# Press Enter to continue."
echo ""
set -x
sudo reboot now
set +x
exit

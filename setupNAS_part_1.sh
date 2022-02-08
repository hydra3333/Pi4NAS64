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
	read -p "Have you completed the pre-Install instructions per README.md on this GIT ? [y/n]? " yn
	case $yn in
		[Yy]* ) OK=y; break;;
		[Nn]* ) OK=n; break;;
		* ) echo "Please answer y or n only.";;
	esac
done
if [ "${OK}" = "n" ]; then
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
echo . "${sdname}"
# Yes there's a ". " at the start of the line '. "${sdname}"'
set -x
. "${sdname}"
set +x
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
sudo mkdir -p ${USB3_mountpoint_1}
sudo chmod -c a=rwx -R ${USB3_mountpoint_1}
if [ "${SecondDisk}" = "y" ]; then
	sudo mkdir -p ${USB3_mountpoint_2}
	sudo chmod -c a=rwx -R ${USB3_mountpoint_2}
fi
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
if [ "${SecondDisk}" = "y" ]; then
	set -x
	sudo sed -i.bak "s/UUID=${USB3_DEVICE_UUID_2}/#UUID=${USB3_DEVICE_UUID_2}/g" "/etc/fstab"
	sudo sed -i.bak "$ a UUID=${USB3_DEVICE_UUID_2} ${USB3_mountpoint_2} ntfs defaults,auto,users,rw,exec,umask=000,dmask=000,fmask=000,uid=$(id -r -u pi),gid=$(id -r -g pi),noatime,nodiratime,x-systemd.device-timeout=120 0 0" "/etc/fstab"
	set +x
fi
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
echo "Now we will reboot the Pi4, so that the USB3 external disk(s) are recognisd by fstab"
echo "and mounted correctly for you to execute PART 2"
echo ""
read -p "# Press Enter to continue."
echo ""
set -x
sudo reboot now
set +x
exit


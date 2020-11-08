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
read -p "# First, confirm default values for the Pi4 and USB3 drives.  Press Enter to continue."
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
echo "# Install https for distros although not strictly needed"
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
sudo apt install -y curl
set +x
echo "# If that did not work, control-C then fix any issues, then re-start this script."
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
echo "# Find and note EXACTLY the correct UUID= string and physical mount point string for the USB3 external hard drive(s)"
echo ""
echo "# The next commands should yield something a bit like this"
echo '# /dev/mmcblk0p1: LABEL_FATBOOT="boot" LABEL="boot" UUID="69D5-9B27" TYPE="vfat" PARTUUID="d9b3f436-01"'
echo '# /dev/mmcblk0p2: LABEL="rootfs" UUID="24eaa08b-10f2-49e0-8283-359f7eb1a0b6" TYPE="ext4" PARTUUID="d9b3f436-02"'
echo '# /dev/sda2: LABEL="5TB-mp4library" UUID="F8ACDEBBACDE741A" TYPE="ntfs" PTTYPE="atari" PARTLABEL="Basic data partition" PARTUUID="6cc8d3fb-6942-4b4b-a7b1-c31d864accef"'
echo '# /dev/mmcblk0: PTUUID="d9b3f436" PTTYPE="dos"'
echo '# /dev/sda1: PARTLABEL="Microsoft reserved partition" PARTUUID="62ac9e1a-a82b-4df7-92b9-19ffc689d80b"'
echo ""
echo "# Look for the Disk Label ... in the above case the UUID is F8ACDEBBACDE741A ... copy and paste the UUID string somewhere as we must use it later"
echo "# Then look for its physical mount point ... in this case it is /dev/sda2 ... copy and paste the string somewhere as we must use it later"
echo "# With a second USB3 drive, both these would be obvious as well ... also copy and paste these strings somewhere as we must use them later"
read -p "# Press Enter to continue."
echo ""
set -x
sudo df
sudo blkid 
set +x
echo ""
echo "# If that did not work, control-C then fix any issues, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
#-------------------------------------------------------------------------------------------------------------------------------------



echo ""
echo "# Note line showing the disk with the label we're interested in eg ${server_USB3_DEVICE_NAME} with UUID=${server_USB3_DEVICE_UUID}"
echo ""
#echo " for kicks, see what filesystems are supported"
#set -x
#ls -al "/lib/modules/$(uname -r)/kernel/fs/"
#set +x

echo ""
echo ""
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "* THIS NEXT BIT IS VERY IMPORTANT - LOOK CLOSELY AND ACT IF NECESSARY                         "
echo "* THIS NEXT BIT IS VERY IMPORTANT - LOOK CLOSELY AND ACT IF NECESSARY                         "
echo ""
echo "# Now we add a line to file /etc/fstab so that the external USB3 drive is installed the same every time"
echo "# (remember, always be consistent and plugin the USB3 drive into the bottom USB3 socket)"
echo "# https://wiki.debian.org/fstab"
echo ""
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
echo "**********************************************************************************************"
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
echo " We MUST check /etc/fstab NOW ... if it is incorrect then abort this process NOW and fix it manually"
echo " We MUST check /etc/fstab NOW ... if it is incorrect then abort this process NOW and fix it manually"
echo " We MUST check /etc/fstab NOW ... if it is incorrect then abort this process NOW and fix it manually"
echo ""
set -x
sudo diff -U 10 "/etc/fstab.old" "/etc/fstab" 
set +x
echo ""
set -x
sudo cat "/etc/fstab"
set +x
echo ""
##read -p "Press Enter if /etc/fstab is OK, otherwise Control-C now and fix it manually !" 

echo ""
echo ""
echo "Get ready for IPv4 only"
set -x
# set a new permanent limit with:
sudo sysctl net.ipv6.conf.all.disable_ipv6=1 
sudo sysctl -p
sudo sed -i.bak "s;net.ipv6.conf.all.disable_ipv6;#net.ipv6.conf.all.disable_ipv6;g" "/etc/sysctl.conf"
echo net.ipv6.conf.all.disable_ipv6=1 | sudo tee -a "/etc/sysctl.conf"
sudo sysctl -p
set +x
echo ""

echo ""
echo "Get ready for minidlna. Increase system max_user_watches to avoid this error:"
echo "WARNING: Inotify max_user_watches [8192] is low or close to the number of used watches [2] and I do not have permission to increase this limit.  Please do so manually by writing a higher value into /proc/sys/fs/inotify/max_user_watches."
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
echo ""
echo ""

#exit

echo "# ------------------------------------------------------------------------------------------------------------------------"
## Build and configure HD-IDLE
cd ~/Desktop
. "./setup_0.2_setup_HD-IDLE.sh"
echo "# ------------------------------------------------------------------------------------------------------------------------"

echo ""
echo ""
echo "Remember, to disable WiFi:"
echo "add this line to '/boot/config.txt' and then reboot for it to take effect"
echo "dtoverlay=pi3-disable-wifi"
echo ""
echo ""
echo "Please Reboot now for the USB disk naming to take effect, before attempting to run setup_1.0.sh"
echo "Please Reboot now for the USB disk naming to take effect, before attempting to run setup_1.0.sh"
echo "Please Reboot now for the USB disk naming to take effect, before attempting to run setup_1.0.sh"
echo ""

exit

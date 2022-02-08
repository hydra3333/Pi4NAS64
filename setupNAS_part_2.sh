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
sudo blkid ${USB3_DISK_NAME_1}
sudo df ${USB3_DISK_NAME_1}
sudo lsblk ${USB3_DISK_NAME_1}
set +x
if [ "${SecondDisk}" = "y" ]; then
	echo "# Attributes of SECOND USB3 DISK"
	set -x
	sudo blkid ${USB3_DISK_NAME_2}
	sudo df ${USB3_DISK_NAME_2}
	sudo lsblk ${USB3_DISK_NAME_2}
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
idle_opts=idle_opts+" -a ${USB3_DISK_NAME_1} -i ${the_sda_timeout} "
if [ "${SecondDisk}" = "y" ]; then
	idle_opts += " -a ${USB3_DISK_NAME_2} -i ${the_sda_timeout} "
fi
idle_opts += " -l /var/log/hd-idle.log\n\""
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


exit



sudo systemctl enable hd-idle
sleep 2s
sudo systemctl restart hd-idle
sleep 2s
set +x
echo ""
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Restart the hd-idle service to doubly ensure use of the updated config"
echo ""
echo "NOTE: hd-idle log file in '/var/log/hd-idle.log'"
echo ""
set -x
sudo systemctl stop hd-idle
sleep 1s
sudo systemctl restart hd-idle
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
echo "#-------------------------------------------------------------------------------------------------------------------------------------"

















#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "We have now completed PART 2 of the setup."
echo ""
echo "Now we will reboot the Pi4, so that the USB3 external disk(s) are recognisd by fstab and mounted correctly, etc."
echo ""
read -p "# Press Enter to continue."
echo ""
set -x
sudo reboot now
set +x
exit


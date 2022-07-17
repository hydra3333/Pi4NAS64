#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
# Determine the settings to apply, based in prior answers.
# Call this .sh like:
## . "./setupNAS_ask_defaults.sh"
# source "./setupNAS_ask_defaults.sh"
#
set +x
cd ~/Desktop
echo "# ------------------------------------------------------------------------------------------------------------------------"
host_name=$(hostname --fqdn)
host_ip=$(hostname -I | cut -f1 -d' ')
setup_config_file=./setupNAS_defaults.config
#
### UPDATES:
### 2022.02.08	variable server_alias -> virtual_folder_name
### 2022.02.08	variable server_root_USB3_mountpoint -> USB3_mountpoint
### 2022.02.08	server_root_folder -> root_folder
#
#---
#
server_name=${host_name}	# IGNORE ANY DEFAULT SERVER NAME, AFFIX TO THE HOST NAME
server_ip=${host_ip}		# IGNORE ANY DEFAULT SERVER IP, AFFIX TO THE HOST IP
#
virtual_folder_name_default_1=""
virtual_folder_name_1=""
USB3_mountpoint_default_1=""
USB3_mountpoint_1=""
root_folder_default_1=""
root_folder_1=""
USB3_DISK_NAME_1=""
USB3_DEVICE_NAME_1=""
USB3_DEVICE_UUID_1=""
#
virtual_folder_name_default_2=""
virtual_folder_name_2=""
USB3_mountpoint_default_2=""
USB3_mountpoint_2=""
root_folder_default_2=""
root_folder_2=""
USB3_DISK_NAME_2=""
USB3_DEVICE_NAME_2=""
USB3_DEVICE_UUID_2=""
#
#mergerfs_mountpoint="/mnt/mergerfs/mp4library"
#mergerfs_mountpoint_default="/mnt/mergerfs/mp4library"
mergerfs_mountpoint_default=""
mergerfs_mountpoint=""
mergerfs_folders=""
mergerfs_virtual_folder_name_default=""
mergerfs_virtual_folder_name=""
#---
#
if [[ -f "$setup_config_file" ]]; then
	echo "Using prior answers as defaults..."
	set -x
	cat "$setup_config_file"
	set +x
	#
	source "$setup_config_file" # use bash "source" to retrieve the previous answers and use those as the defaults in prompting
fi
#
#---
#
if [[ "${virtual_folder_name_default_1}" = "" ]]; then virtual_folder_name_default_1=mp4library1; fi;
read -e -p "Designate the FIRST virtual_folder_name (will become the FIRST Virtual Folder share name) [${virtual_folder_name_default_1}]: " -i "${virtual_folder_name_default_1}" input_string
virtual_folder_name_1="${input_string:-$virtual_folder_name_default_1}" # forces the name to be the original default if the user erases the input or default (submitting a null).
#
if [[ "${USB3_mountpoint_default_1}" = "" ]]; then  USB3_mountpoint_default_1=/mnt/${virtual_folder_name_1}; fi
read -e -p "Designate the mount point for the FIRST USB3 external hard drive [${USB3_mountpoint_default_1}]: " -i "${USB3_mountpoint_default_1}" input_string
USB3_mountpoint_1="${input_string:-$USB3_mountpoint_default_1}" # forces the name to be the original default if the user erases the input or default (submitting a null).
#
if [[ "${root_folder_default_1}" = "" ]]; then root_folder_default_1=${USB3_mountpoint_1}/${virtual_folder_name_1}; fi
read -e -p "Designate the physical root folder on the FIRST USB3 external hard drive [${root_folder_default_1}]: " -i "${root_folder_default_1}" input_string
root_folder_1="${input_string:-$root_folder_default_1}" # forces the name to be the original default if the user erases the input or default (submitting a null).
#
#
if [[ "${mergerfs_virtual_folder_name_default}" = "" ]]; then mergerfs_virtual_folder_name_default=mp4library; fi;
read -e -p "Designate the mergerfs virtual_folder_name  [${mergerfs_virtual_folder_name_default}]: " -i "${mergerfs_virtual_folder_name_default}" input_string
mergerfs_virtual_folder_name="${input_string:-$mergerfs_virtual_folder_name_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
#
if [[ "${mergerfs_mountpoint_default}" = "" ]]; then  mergerfs_mountpoint_default=/mnt/mergerfs/${mergerfs_virtual_folder_name}; fi
read -e -p "Designate the mount point for the 'mergerfs' virtual disk for NFS [${mergerfs_mountpoint_default}]: " -i "${mergerfs_mountpoint_default}" input_string
mergerfs_mountpoint="${input_string:-$mergerfs_mountpoint_default}" # forces the name to be the original default if the user erases the input or default (submitting a null).
mergerfs_folders="${root_folder_1}"
mergerfs_root_folder=${mergerfs_mountpoint}
#
#---
#
SecondDisk=n
# if not already sourced from the saved config file, pre-set these to "_2" values anyway, in case as-yet there is NOT a SECOND disk
#
while true; do
	read -p "Do you have a Second Media Disk [y/n]? " yn
	case $yn in
		[Yy]* ) SecondDisk=y; break;;
		[Nn]* ) SecondDisk=n; break;;
		* ) echo "Please answer y or n only.";;
	esac
done
if [[ "${SecondDisk}" = "y" ]]; then
	if [[ "${virtual_folder_name_default_2}" = "" ]]; then virtual_folder_name_default_2=mp4library2; fi;
	read -e -p "Designate the SECOND virtual_folder_name (will become the SECOND Virtual Folder share name) [${virtual_folder_name_default_2}]: " -i "${virtual_folder_name_default_2}" input_string
	virtual_folder_name_2="${input_string:-$virtual_folder_name_default_2}" # forces the name to be the original default if the user erases the input or default (submitting a null).
	#
	if [[ "${USB3_mountpoint_default_2}" = "" ]]; then USB3_mountpoint_default_2=/mnt/${virtual_folder_name_2}; fi;
	read -e -p "Designate the mount point for the SECOND USB3 external hard drive [${USB3_mountpoint_default_2}]: " -i "${USB3_mountpoint_default_2}" input_string
	USB3_mountpoint_2="${input_string:-$USB3_mountpoint_default_2}" # forces the name to be the original default if the user erases the input or default (submitting a null).
	#
	if [[ "${root_folder_default_2}" = "" ]]; then root_folder_default_2=${USB3_mountpoint_2}/${virtual_folder_name_2}; fi;
	read -e -p "Designate the physical root folder on the SECOND USB3 external hard drive [${root_folder_default_2}]: " -i "${root_folder_default_2}" input_string
	root_folder_2="${input_string:-$root_folder_default_2}" # forces the name to be the original default if the user erases the input or default (submitting a null).
	#
	mergerfs_folders="${mergerfs_folders}:${root_folder_2}"
else
	if [[ "${virtual_folder_name_default_2}" = "" ]]; then virtual_folder_name_default_2=mp4library2; fi;
	if [[ "${USB3_mountpoint_default_2}" = "" ]]; then USB3_mountpoint_default_2=/mnt/${virtual_folder_name_default_2}; fi;
	if [[ "${root_folder_default_2}" = "" ]]; then root_folder_default_2=${USB3_mountpoint_2}/${virtual_folder_name_default_2}; fi;
	if [[ "${virtual_folder_name_2}" = "" ]]; then virtual_folder_name_2=virtual_folder_name_default_2; fi
	if [[ "${USB3_mountpoint_2}" = "" ]]; then USB3_mountpoint_2=USB3_mountpoint_default_2; fi
	if [[ "${root_folder_2}" = "" ]]; then root_folder_2=root_folder_default_2; fi
fi
#
# ALWAYS choose a USB3 Disk device and find it's UUID
# (The use/positioning of parentheses and curly-brackets in setting array elements is critical)
#
disk_name=()
device_label=()
device_uuid=()
device_fstype=()
device_size=()
device_mountpoint=()
while IFS= read -r -d $'\0' device; do
   d=$device
   device=${d/\/dev\//}
   x_disk_name=($device)
   x_device_name=($d)
   x_device_label="$(lsblk -n -p -l -o label ${d})"
   #x_device_uuid="$(blkid -o value -s UUID ${d})"
   x_device_uuid="$(lsblk -n -p -l -o uuid ${d})"
   x_device_fstype="$(lsblk -n -p -l -o fstype ${d})"
   x_device_size="$(lsblk -n -p -l -o size ${d})"
   x_device_mountpoint="$(lsblk -n -p -l -o mountpoint ${d})"
   #echo "***********************************"
   #echo "EXAMIMING NEW DEVICE:"
   #echo "d=${d}"
   #echo "device=${device}"
   #echo "x_disk_name=${x_disk_name}"
   #echo "x_device_label=${x_device_label}"
   #echo "x_device_uuid=${x_device_uuid}"
   #echo "x_device_fstype=${x_device_fstype}"
   #echo "x_device_size=${x_device_size}"
   #echo "x_device_mountpoint=${x_device_mountpoint}"
   #echo "***********************************"
   if [[ "${x_device_uuid}" != "" ]] ; then
      #echo "FOUND device valid x_device_name=${x_device_name}"
      disk_name+=("${x_disk_name}")
      device_name+=("${x_device_name}")
      device_label+=("${x_device_label}")
      #device_uuid+=("${x_device_uuid}")
      device_uuid+=("${x_device_uuid}")
      device_fstype+=("${x_device_fstype}")
      device_size+=("${x_device_size}")
      device_mountpoint+=("${x_device_mountpoint}")
   fi
done < <(find "/dev/" -regex '/dev/sd[a-z][0-9]\|/dev/vd[a-z][0-9]\|/dev/hd[a-z][0-9]' -print0)
#---
#echo "????????????????????????"
#for t in ${disk_name[@]}; do
#  echo "1. ???? disk name=${t}"
#done
#echo "????????????????????????"
#for jj in ${!disk_name[@]}; do
#  echo "2. ???? jj=$jj disk name=${disk_name[$jj]}"
#done
#echo "????????????????????????"
#---
device_string_tabbed=()
device_string=()
for i in `seq 0 $((${#disk_name[@]}-1))`; do
   device_string+=("DISK=${disk_name[$i]}, DEVICE==${device_name[$i]}, LABEL=${device_label[$i]}, UUID=${device_uuid[$i]}, FS_TYPE=${device_fstype[$i]}, SIZE=${device_size[$i]}, MOUNT_POINT=${device_mountpoint[$i]}")
   device_string_tabbed+=("${disk_name[$i]}\t${name[$i]}\t${size[$i]}\t${device_name[$i]}\t${device_label}\t${device_uuid[$i]}\t${device_fstype[$i]}\t${device_size[$i]}\t${device_mountpoint[$i]}")
   echo "DISK=${disk_name[$i]}, DEVICE==${device_name[$i]}, LABEL=${device_label[$i]}, UUID=${device_uuid[$i]}, FS_TYPE=${device_fstype[$i]}, SIZE=${device_size[$i]}, MOUNT_POINT=${device_mountpoint[$i]}"
   #echo "ls -al ${device_mountpoint[$i]}/"
   ls -al "${device_mountpoint[$i]}/"
   echo ""
done
#---
#echo "????????????????????????"
#for i in `seq 0 $((${#disk_name[@]}-1))`; do
#   echo "i=${i} disk_name[${i}]=${disk_name[$i]}"
#done
#echo "????????????????????????"
#for i in `seq 0 $((${#disk_name[@]}-1))`; do
#   echo -e "TEST TABBED QUERY RESULTS: ${i} ${device_string_tabbed[$i]}"
#done
#echo "????????????????????????"
#for i in `seq 0 $((${#disk_name[@]}-1))`; do
#   echo -e "TEST NON-TABBED QUERY RESULTS: ${i} ${device_string[$i]}"
#done
#echo "????????????????????????"
#---
#--- Start function
menu_from_array () {
 select item; do
   # Check the selected menu item number
   #echo "*** REPLY=${REPLY} *** item=${item}"
   if [[ 1 -le "$REPLY" ]] && [[ "$REPLY" -le $# ]]; then
      if [[ "$REPLY" -eq $# ]]; then
		let "selected_index=-1"
		selected_item=""
		echo "EXITING: selected_index:${selected_index} selected_item:${selected_item}..."
		break;
      fi
      let "selected_index=${REPLY} - 1"
      selected_item=${item}
      echo "The selected operating system is ${selected_index} ${selected_item}"
      break;
   else
      echo "Invalid number entered: Select any number from 1-$#"
   fi
 done
}
#--- End Function
#---
echo ""
echo "Choose which device is the FIRST USB3 hard drive/partition containing the .mp4 files ! "
echo ""
exit_string="It isn't displayed, Exit immediately"
menu_from_array "${device_string[@]}" "${exit_string}"
if [[ "${selected_index}" -eq "-1" ]]; then
	exit
fi
USB3_DISK_NAME_1="${disk_name[${selected_index}]}"
USB3_DEVICE_NAME_1="${device_name[${selected_index}]}"
USB3_DEVICE_UUID_1="${device_uuid[${selected_index}]}"
#
if [[ "${SecondDisk}" = "y" ]]; then
	echo ""
	echo "Choose which device is the SECOND USB3 hard drive/partition containing the .mp4 files ! "
	echo ""
	exit_string="It isn't displayed, Exit immediately"
	menu_from_array "${device_string[@]}" "${exit_string}"
	if [[ "${selected_index}" -eq "-1" ]]; then
		SecondDisk=n
		USB3_DISK_NAME_2=""
		USB3_DEVICE_NAME_2=""
		USB3_DEVICE_UUID_2=""
	else 
		USB3_DISK_NAME_2="${disk_name[${selected_index}]}"
		USB3_DEVICE_NAME_2="${device_name[${selected_index}]}"
		USB3_DEVICE_UUID_2="${device_uuid[${selected_index}]}"
	fi
fi
echo ""
#
echo "(re)Saving the new answers to the config file for re-use as future defaults..."
echo ""
sudo rm -fv "$setup_config_file"
echo "server_name=${server_name}">> "$setup_config_file"
echo "server_ip=${server_ip}">> "$setup_config_file"
echo ""
echo "virtual_folder_name_1=${virtual_folder_name_1}">> "$setup_config_file"
echo "virtual_folder_name_default_1=${virtual_folder_name_1}">> "$setup_config_file"
echo "USB3_mountpoint_1=${USB3_mountpoint_1}">> "$setup_config_file"
echo "USB3_mountpoint_default_1=${USB3_mountpoint_1}">> "$setup_config_file"
echo "root_folder_1=${root_folder_1}">> "$setup_config_file"
echo "root_folder_default_1=${root_folder_1}">> "$setup_config_file"
echo "USB3_DISK_NAME_1=${USB3_DISK_NAME_1}">> "$setup_config_file"
echo "USB3_DEVICE_NAME_1=${USB3_DEVICE_NAME_1}">> "$setup_config_file"
echo "USB3_DEVICE_UUID_1=${USB3_DEVICE_UUID_1}">> "$setup_config_file"
echo ""
echo "SecondDisk=${SecondDisk}">> "$setup_config_file"
echo "virtual_folder_name_2=${virtual_folder_name_2}">> "$setup_config_file"
echo "virtual_folder_name_default_2=${virtual_folder_name_2}">> "$setup_config_file"
echo "USB3_mountpoint_2=${USB3_mountpoint_2}">> "$setup_config_file"
echo "USB3_mountpoint_default_2=${USB3_mountpoint_2}">> "$setup_config_file"
echo "root_folder_2=${root_folder_2}">> "$setup_config_file"
echo "root_folder_default_2=${root_folder_2}">> "$setup_config_file"
echo "USB3_DISK_NAME_2=${USB3_DISK_NAME_2}">> "$setup_config_file"
echo "USB3_DEVICE_NAME_2=${USB3_DEVICE_NAME_2}">> "$setup_config_file"
echo "USB3_DEVICE_UUID_2=${USB3_DEVICE_UUID_2}">> "$setup_config_file"
echo ""
echo "mergerfs_virtual_folder_name_default=${mergerfs_virtual_folder_name_default}">> "$setup_config_file"
echo "mergerfs_virtual_folder_name=${mergerfs_virtual_folder_name}">> "$setup_config_file"
echo "mergerfs_mountpoint_default=${mergerfs_mountpoint_default}">> "$setup_config_file"
echo "mergerfs_mountpoint=${mergerfs_mountpoint}">> "$setup_config_file"
echo "mergerfs_folders=${mergerfs_folders}">> "$setup_config_file"
echo "mergerfs_root_folder=${mergerfs_root_folder}">> "$setup_config_file"
#
echo "#">> "$setup_config_file"
set -x
sudo chmod -c a=rwx -R "$setup_config_file"
cat "$setup_config_file"
set +x
echo ""
echo "***** SAVED DEFAULTS :-"
echo "               server_name=${server_name}"
echo "                 server_ip=${server_ip}"
echo ""
echo "  FIRST virtual_folder_name_1=${virtual_folder_name_1}"
echo "            USB3_mountpoint_1=${USB3_mountpoint_1}"
echo "                root_folder_1=${root_folder_1}"
echo "             USB3_DISK_NAME_1=${USB3_DISK_NAME_1}"
echo "           USB3_DEVICE_NAME_1=${USB3_DEVICE_NAME_1}"
echo "           USB3_DEVICE_UUID_1=${USB3_DEVICE_UUID_1}"
echo ""
if [[ "${SecondDisk}" = "y" ]]; then
	echo "             SecondDisk=${SecondDisk}"
	echo " SECOND virtual_folder_name_2=${virtual_folder_name_2}"
	echo "            USB3_mountpoint_2=${USB3_mountpoint_2}"
	echo "                root_folder_2=${root_folder_2}"
	echo "             USB3_DISK_NAME_2=${USB3_DISK_NAME_2}"
	echo "           USB3_DEVICE_NAME_2=${USB3_DEVICE_NAME_2}"
	echo "           USB3_DEVICE_UUID_2=${USB3_DEVICE_UUID_2}"
fi
echo ""
echo "          mergerfs_mountpoint=${mergerfs_mountpoint}"
echo "             mergerfs_folders=${mergerfs_folders}"
echo " mergerfs_virtual_folder_name=${mergerfs_virtual_folder_name}"
echo "         mergerfs_root_folder=${mergerfs_root_folder}"
echo "*****"
echo ""
echo "# ------------------------------------------------------------------------------------------------------------------------"

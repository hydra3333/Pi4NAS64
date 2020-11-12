#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i.bak s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
set -x
cd ~/Desktop

echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "OK, please visually check some settings on the Pi4"
echo ""
set -x
sudo ifconfig
sudo hostname
sudo hostname --fqdn
sudo hostname --all-ip-addresses
set +x

# Ask for and setup default settings and try to remember them. Yes there's a ". " at the start of the line".
sdname=./setupNAS_ask_defaults.sh
echo . "${sdname}"
set -x
. "${sdname}"
set +x
echo ""

echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "################################################################################################################################"
echo ""
echo "# Install NFS and create the file shares"
echo ""
read -p "# Press Enter to continue."
echo ""
# https://magpi.raspberrypi.org/articles/raspberry-pi-samba-file-server
# https://pimylifeup.com/raspberry-pi-samba/
echo ""
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Un-Install any previous NFS install ... no, just stop it instead."
echo ""
nfs_export_top="/NFS-shares"
nfs_export_full="${nfs_export_top}/mp4library"
nfs_export_full2="${nfs_export_top}/mp4library2"
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
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
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
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
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
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
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
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
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
echo ""
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
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
echo ""
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
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
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
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
echo ""
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "# Now list the content of the fsexport the definitions to make them available"
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
echo ""
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "Now cleanup ..."
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
sudo mount -v -t nfs ${server_ip}:/${nfs_export_full} "/tmp-NFS-mountpoint"
echo sudo mount -v -t nfs ${server_ip}:/${nfs_export_full} "/tmp-NFS-mountpoint">>"${f_ls_nsf}"
sudo ls -al "/tmp-NFS-mountpoint/"
echo # list files in the main share ">>"${f_ls_nsf}"
echo sudo ls -al "/tmp-NFS-mountpoint/">>"${f_ls_nsf}"
sudo umount -f "/tmp-NFS-mountpoint"
echo sudo umount -f "/tmp-NFS-mountpoint">>"${f_ls_nsf}"
if [ "${SecondaryDisk}" = "y" ]; then
	sudo umount -f "/tmp-NFS-mountpoint2"
	echo sudo umount -f "/tmp-NFS-mountpoint2">>"${f_ls_nsf}"
	sudo mkdir -p "/tmp-NFS-mountpoint2"
	echo sudo mkdir -p "/tmp-NFS-mountpoint2">>"${f_ls_nsf}"
	sudo chmod -c a=rwx -R "/tmp-NFS-mountpoint2"
	echo sudo chmod -c a=rwx -R "/tmp-NFS-mountpoint2">>"${f_ls_nsf}"
	#sudo ls -al "/tmp-NFS-mountpoint2"
	sudo mount -v -t nfs ${server_ip}:/${nfs_export_full2} "/tmp-NFS-mountpoint2"
	echo sudo mount -v -t nfs ${server_ip}:/${nfs_export_full2} "/tmp-NFS-mountpoint2">>"${f_ls_nsf}"
	sudo ls -al "/tmp-NFS-mountpoint2/"
	echo # list files in the secondary share ">>"${f_ls_nsf}"
	echo sudo ls -al "/tmp-NFS-mountpoint2/">>"${f_ls_nsf}"
	sudo umount -f "/tmp-NFS-mountpoint2"
	echo sudo umount -f "/tmp-NFS-mountpoint2">>"${f_ls_nsf}"
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
echo "#-------------------------------------------------------------------------------------------------------------------------------------"


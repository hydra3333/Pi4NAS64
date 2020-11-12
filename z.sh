#!/bin/bash
# to get rid of MSDOS format do this to this file: sudo sed -i.bak s/\\r//g ./filename
# or, open in nano, control-o and then then alt-M a few times to toggle msdos format off and then save
#
echo "#-------------------------------------------------------------------------------------------------------------------------------------"
set -x
cd ~/Desktop
set +x
echo ""
echo "# Have we completed the pre-Install set of instructions per the Readme ?"
echo "# If not, control-C then do them, then re-start this script."
read -p "# Otherwise - Press Enter to continue."
echo ""
echo "#-------------------------------------------------------------------------------------------------------------------------------------"

echo "#-------------------------------------------------------------------------------------------------------------------------------------"
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
sleep 10
echo sleep 10>>"${f_ls_nsf}"
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
	sleep 10
	echo sleep 10>>"${f_ls_nsf}"
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
echo "Now you can run this .sh file :-"
echo ""
set -x
ls -al "${f_ls_nsf}"
set +x
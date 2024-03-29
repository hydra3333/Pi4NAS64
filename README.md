# Pi4NAS64 for x64    
## update: for Raspberry Pi OS x64 ONLY    

### a Raspberry Pi4 NAS for use by "Google ChromeCast with Google TV" devices   

---

## Description <TL;DR> 

Configure a Raspberry Pi4 with attached USB3 drives to create an NAS on our local home LAN with 
- "open" NFS   file share to a "mergerfs" virtual disk of "merged folders" across Pi4 drives    
- "open" SAMBA file share to a "mergerfs" virtual disk of "merged folders" across Pi4 drives    
- "open" rw SAMBA file shares to drives containing media   
- "open" rw ftp server (`proftpd`)   
- a DLNA server (`miniDLNA`)   
- the `hd-idle` app to spin down drives when not used   

The newly released "Google ChromeCast with Google TV" devices can connect to the Pi4NAS64 
with apps like `VLC` in order to play collections of home media files via the NFS share.    

A Raspbetty Pi 4 is comparatively cheap, has very low power usage, is extremely reliable, and has decent thoughput to handle multiple streams.

"Google ChromeCast with Google TV" : https://store.google.com/au/product/chromecast_google_tv_specs

---

## Assumptions     


1. We have One or perhaps Two USB3 external hard drives full of videos, to attach to the Raspbetty Pi    
   - these USB3 drives must be formatted as NTFS by Windows, and have security set to `Everyone` having `Full Access` to the top level and all subfolders and files
   - first USB3 drive has characteristics:    
     * Drive label `mp4library1`    
     * a folder at the root level of the first USB3 drive must be `mp4library1` and have security set to `Everyone` having `Full Access` to this folder and all subfolders    
   - second USB3 drive has characteristics:    
     * Drive label `mp4library2`    
     * a folder at the root level of the first USB3 drive must be `mp4library2` (NOT the same as the first drive) and have security set to `Everyone` having `Full Access` to this folder and all subfolders    

2. We choose to sometimes detach the USB3 drives from the Raspberry Pi4 and temporarily attach them to a Windows 10 PC to copy large media files onto them    
   - as we all know, USB3 file copy speeds will be *much* greater for locally attached drives vs copying cross the network    

3. The Raspberry Pi4 is connected to our home LAN via wired ethernet (we`ll turn off bluetooth and WiFi)     
   - as we all know, from actual testing, WiFi is subject to contention which limits bandwidth and this may cause lag/stuttering when playing media on devices accessing the shares    

4. We **must** allocate a fixed IPv4 address for our Pi4, perhaps by assigning it a permanent IPv4 lease in DHCP in our home router   
   -  this is really important

5. "Google ChromeCast with Google TV" devices are ideally connected to our home LAN via wired ethernet    
   - as we all know, from actual test results, WiFi is subject to contention which limits bandwidth and this may cause lag/stuttering when playing media    

6. After setup, the monitor/mouse/keyboard can be disconnected from the Pi4 so as to run "headless"    

7. The Pi4 will *not* perform any *external* network connections outside our home LAN at runtime, other than for normal Raspberry Pi O/S operations and its software updates   

8. We will run the **64-bit** version of Raspberry Pi O/S and apps    

9. Of probable interest, playable .mp4 files are    
   - not interlaced (a `Chromecast Ultra` device will not play them, and probably not the "Google ChromeCast with Google TV" either)    
   - max resolution of `1080p` and having an `SDR` colour scheme (unless we have a `Chromecast Ultra` device, in which case `4K` and `HDR`)
   - ideally encoded with codecs `h.264(avc)/aac` ... or `h.265(hevc)/aac`
   - videos encoded with `hevc/avc` won`t play in a Chrome browser, but they *will* cast to and play on a Chromecast device 
     * (... neither type of video plays inside a Pi`s Chromium browser, unfortunately) 
   - Google's *probably out-of-date list* of acceptable .mp4 codecs for the `Chromecast Ultra` is at https://developers.google.com/cast/docs/media but as yet we can`t find one for the "Google ChromeCast with Google TV"

10. We could try using a Raspberry Pi 3b+ instead of a Pi 4, it would build fine, however 
    - it only has USB2 ports to attach the external drives, which may not provide enough bandwidth one needs to deliver uninterrupted streams
    - its "limited" ethernet interface may not provide enough bandwidth one needs to deliver uninterrupted streams

---

## Pre-Installaton stuff which **must** be correctly setup first    

1. Ensure our USB3 drives are plugged into the Pi4   

2. Install and configure our Raspberry Pi4 4Gb or 8Gb   
   - Install 64-bit Raspberry Pi O/S and configure it to how we like it   
   - Check/configure the software library options and ensure latest OS updates are applied   
      - start a Terminal, then do this (perhaps a reboot will be needed afterward, if so do that too)   
         ```
         sudo sed -i.bak "s/#deb/deb/g" "/etc/apt/sources.list"
         sudo apt -y update   
         sudo apt -y full-upgrade
		 #sudo reboot now
         ```   

   - AFTER BOOTING 64-bit Raspberry Pi O/S FOR THE FIRST TIME, and it having auto-re-sized the disk etc:   
      - it will ask for the Country etc. Choose
         - Country ```Australia```   
         - Language ```Australian English```   
         - TimeZone ```Adelaide```   
         - for Keyboard tick both ```Use English Language``` and ```Use US Keyboard```   
      - it will ask for a new password, so set one   
      - it will ask for Set Up Screen, set your options   
      - it will ask to choose WiFi network, choose the ```Skip``` button (we use hard-wired ethernet to not flood the WiFi toward the Router)   
      - it will ask to Update Software, choose ```Next```   
      - then the first-time setup will exit   
      - NOW PLUG IN THE USB3 DISKS
         - if there are prompts about the USB3 disks, choose ```cancel```   
      - Now use the Pi gui main menu, choose ```Logout``` and then ```Reboot```   
   - AFTER REBOOTING and auto-logging into the gui   
      - if there are prompts about the USB3 disks, choose ```cancel```   
      - Use the Pi gui main menu, choose Preferences, Raspberry Pi Configuration and a dialogue box with tabs will appear   
         - In ```System``` tab choose   
            - ```Hostname``` as ```PI4NAS64```   
            - ```Boot``` as ```To Desktop```   
            - ```Auto login``` as ```ON```   
            - ```Network at Boot``` as ```OFF```   
            - ```Splash Screen``` as ```OFF```   
         - In ```Display``` tab choose
            - ```Overscan``` is ```OFF```   
            - ```Pixed Doubing``` is ```OFF```   
            - ```Screen Blanking``` is ```ON```   
            - ```Headless Resolution``` is ```1920x1080```   
         - In ```Interfaces``` tab choose
            - ```SSH``` is ```ON```   
            - ```VNC``` is ```ON```   
            - the other settings are ```OFF```   
         - In ```Performance``` tab choose   
            - ```GPU Memory``` is ```256```   
            - ignore the other settings   
         - In ```Localisation``` tab choose   
            - ```Locale``` ```Language```=```en (English)``` ```Country```=```AU (Australia)``` ```Character Set```=```UTF-8```   
            - ```Timezone``` ```Area```=```Australia``` ```Location```=```Adelaide```   
            - ```Keyboard``` ```Model```=```Generic 105 (intl)``` ```Layout```=```English (Australian)``` ```Variant```=```English (Australian)```   
            - ```WiFi Country``` ```WiFi Country Code```=```Au Australia```   
         - Click ```OK```, then for ```Would you like to reboot now ?``` choose ```Yes```   
         - If it does not ask to reboot, then use the Pi gui main menu, choose ```Logout``` and then ```Reboot```   
   - AFTER REBOOTING and auto-logging into the gui, check/configure the rest of the options.   
      - start a Terminal to do ```sudo raspi-config``` and see a menu box appear   
      - Under ```1 System Options``` choose
         - ```S4 Hostname``` check/reset to ```PI4NAS64```   
         - ```S5 Boot/Auto Login``` check/reset to ```B4 Desktop GUI, automatically logged in as pi```   
         - ```S6 Network at Boot``` check/reset to ```No```   
         - ```S7 Splash Screen``` check/reset to ```No```   
      - Under ```2 Display Options``` choose
         - ```D4 Screen Blanking``` check/reset to ```No```   
         - ```D5 VNC Resolution``` check/reset to ```1920x1080```   
      - Under ```3 Interface Options``` choose   
         - ```I2 SSH``` check/reset to ```Yes```   
         - ```I3 VNC``` check/reset to ```Yes```   
      - Under ```4 Performance Options``` choose   
         - ```GPU Memory``` check/reset to ```256```   
      - Under ```5 Localisation Options``` choose   
         - ```L1 Locale``` language and charater set ```en_AU.UTF-8 UTF-8``` and confirm on next screen as ```en_AU.UTF-8 UTF-8```   
         - ```L2 Timzone``` check/reset to ```Australia``` and ```Adelaide```   
         - ```L4 WLAN``` check/reset to ```AU Australia```   
      - Under ```6 Advanced Options``` choose   
         - ```A1 Expand Filesystem``` say ```yes```   
         - ```A4 Network Interface Names``` say ```yes```   
         - ```A6 Boot Order``` choose ```B1 SD Card```   
         - ```A7 Boot Loader Version``` as ```latest```   
      - Now ```Finish```
         - If it does not ask to reboot, then use the Pi gui main menu, choose ```Logout``` and then ```Reboot```   

3. If the Pi4 is Wired ethernet (it should be, so that it halves WiFi traffic/contention eg cuts out the hop from the Pi to Router), disable WiFi and BlueTooth on the Pi4   
   - ... perhaps in a Terminal use `sudo nano /boot/config.txt` to edit the file.   
   - add this line **at the TOP into** `/boot/config.txt` to force time for the USB3 disks to spin up   
      ```
      boot_delay=30
      ```
   - then add these lines near the END (**before all of these label lines** `[cm4] [All] [pi4] [All]`) into `/boot/config.txt` to disable WiFi and bluetooth   
 
      ```
      dtoverlay=disable-wifi   
      dtoverlay=disable-bt   
      ```   
      and then reboot the Pi4   

4. Ensure the Pi has a fixed IPv4 address   
   - ideally by using our home router's DHCP facility to recognise the Pi`s mac address and provide it with an ongoing fixed IPv4 address lease   
   - ensure the Pi4 is rebooted so the new fixed IPv4 address "sticks"
   - then start a Terminal and use `ifconfig` to check the IPv4 address has "stuck"   

5. Prepare our USB3 drives - before we even go near plugging them into the Pi4
   - plug the drive(s) into a Windows PC 
   - format then as NTFS 
   - set security on the drive itself to `Everyone` having `Full Access`
   - set security on the top level and all subfolders and files to `Everyone` having `Full Access`
     * hint: one may need to change "inherited permissions"
   - first USB3 drive has characteristics:    
     * Drive label `mp4library1`    
     * a folder at the root level of the first USB3 drive must be `mp4library1` and have security set to `Everyone` having `Full Access` to this folder and all subfolders and files    
   - (if one has one) second USB3 drive has characteristics:    
     * Drive label `mp4library2`    
     * a folder at the root level of the first USB3 drive must be `mp4library2` (NOT the same as the first drive) and have security set to `Everyone` having `Full Access` to this folder and all subfolders and files 
   - copy media files into the folder tree one created, and check security permissikons on them is set correctly	 

6. Cross-check **everything** and **Reboot the Pi4** one last time to ensure all settings are good and being used !

---

## Install the NAS related apps into the Pi4    

1. Re-check that the Pi4 has been pre-configured correctly, particularly the server-name and fixed IPv4 address    

2. Prepare our USB3 drives on the Pi4
   - **plug the USB3 external hard drive(s)** into the Pi4 
      - always plug the FIRST drive into the "TOP" USB3 slot
      - always plug the SECOND drive into the "BOTTOM" USB3 slot
      - always plug the same drives into the same USB3 slots every time !
   - wait 15 to 30 seconds for the USB3 external hard drives to spin up and be mounted automatically; ignore/cancel any prompts at thie time   
   - find and note EXACTLY the correct `UUID=` string of letters and numbers for the USB3 external hard drive(s) ... start a Terminal and do this:
     ```
     sudo df
     sudo blkid 
     ```
     * which should yield something like this
       ```
       /dev/mmcblk0p1: LABEL_FATBOOT="boot" LABEL="boot" UUID="69D5-9B27" TYPE="vfat" PARTUUID="d9b3f436-01"
       /dev/mmcblk0p2: LABEL="rootfs" UUID="24eaa08b-10f2-49e0-8283-359f7eb1a0b6" TYPE="ext4" PARTUUID="d9b3f436-02"
       /dev/sda2: LABEL="5TB-mp4library" UUID="F8ACDEBBACDE741A" TYPE="ntfs" PTTYPE="atari" PARTLABEL="Basic data partition" PARTUUID="6cc8d3fb-6942-4b4b-a7b1-c31d864accef"
       /dev/mmcblk0: PTUUID="d9b3f436" PTTYPE="dos"
       /dev/sda1: PARTLABEL="Microsoft reserved partition" PARTUUID="62ac9e1a-a82b-4df7-92b9-19ffc689d80b"
       ```
     * look for the Disk Label ... in the above case the UUID is `F8ACDEBBACDE741A` ... copy and paste the UUID string somewhere as we must use it later
     * then look for its physical mount point ... in this case it is `/dev/sda2` ... copy and paste the string somewhere as we must use it later
     * with a second USB3 drive, both these would be obvious as well ... also copy and paste these strings somewhere as we must use them later 

3. Clone the Pi4NAS64 Github respository to the Desktop of the Pi and copy the setup files to the Desktop
   - start a Terminal and do this:
     ```
     cd ~/Desktop   
     sudo apt install -y git   
     sudo rm -vfR ./Pi4NAS64   
     git clone https://github.com/hydra3333/Pi4NAS64.git   
     cp -fv ./Pi4NAS64/*.sh ./   
     sudo chmod +777 *.sh   
     # determine the user and group numbers (both should be 1000)   
     id -u pi   
     id -g pi    
     echo "uid=$(id -r -u pi) gid=$(id -r -g pi)"   
     ```

4. Now, start a Terminal and start **Part_1** of the install/configure process:
     ```
     cd ~/Desktop
     chmod +777 *.sh
     ./setupNAS_part_1.sh 2>&1 | tee setupNAS_part_1.log
     ```
5. Answer the prompts (it will save most of these answers for use later)
   - `This server_name` it's best to choose the Pi4's hostname of the Pi4 here (we use Pi4NAS64) - it will be used as the network service name by `VLC` etc
   - `This server_alias (will become a Virtual Folder for mounting purposes)` - recommend leave it as `mp4library1` so it matches the top level folder name on the USB3 drive
     * ... it will be used as the top-level folder name on our external USB3 drive, so put our video files in there
   - `Designate the mount point for the USB3 external hard drive` it's a "virtual" place used everywhere to access the top level of the USB3 external hard drive when mounted, eg `/mnt/mp4library1`
   - `Designate the root folder on the USB3 external hard drive` it's the top level folder on the USB3 external hard drive containing .mp4 files and subfolders containing .mp4 files, eg `/mnt/mp4library1/mp4library1`

7. Answer more prompts    
   - sometimes we will be asked to visually scan and check setup results for issues, and to press Enter to continue

8. When the process completes, it will Reboot the Pi4 so that Part_1 settings take effect, before ytou can successfully start Part_2

9. After the reboot from Part_1, start a Terminal and start **Part_2** of the install/configure process, to install hd-idle, NFS, SAMBA:
     ```
     cd ~/Desktop
     chmod +777 *.sh
     ./setupNAS_part_2.sh 2>&1 | tee setupNAS_part_2.log
     ```

6. Answer more prompts , similar to Part_1   
   - when we see something like this:
     ```
     Before we start the server, we’ll want to set a Samba password. Enter we pi password.
     + sudo smbpasswd -a pi
     New SMB password:
     ```
     enter the password we had set for the 'pi' login,    
     then enter it again when we see `Retype new SMB password:`    
   
   - then when we see something like this AGAIN,    
     ```
     Before we start the server, we’ll want to set a Samba password. Enter we pi password.
     + sudo smbpasswd -a root
     New SMB password:
     ```
     again enter the password we had set for the 'pi' login,    
     then enter it when we see `Retype new SMB password:`   

---

## How to connect to the "mergerfs" NFS share from a Windows 10 PC    

1. Ensure microsoft `NFS client` is installed on the Windows 10 PC    
   - in Control Panel, Programs and Features, Turn Windows Features on or off, tick "Services for NFS" and click OK
   - then do the commands below in a Windows 10 DOS BOX

2. Assuming the `IP address` of the Pi4 is `10.0.0.18`, display the available NFS shares on that server in 2 different ways    
   ```
   showmount -e 10.0.0.18
   showmount -a 10.0.0.18
   ```

3. Assuming the name of the 'mergerfs' NFS share is `/NFS-shares/mp4library`, and a free drive letter is `X:` then mount the share    
   ```
   mount -o anon -o mtype=soft 10.0.0.18:/NFS-shares/mp4library X:
   mount
   ```
   
4. Display files on the NFS share when in a DOS box    
   ```
   dir X:
   ```

5. You can also use Windows File Manager to browse the X: drive and play media normally    

6. Dismount the NFS share on drive X: once we have finished with it    
   ```
   umount -f X:
   ```

---

## Also see ...

How to setup a Raspberry Pi 4 as a NAS using NFS with an external USB3 disk    
https://www.raspberrypi.org/forums/viewtopic.php?f=91&t=289118&p=1751528#p1751528    

How to setup a Raspberry Pi 4 as a NAS using SAMBA with an external USB3 disk    
https://www.raspberrypi.org/forums/viewtopic.php?f=91&t=289943    

Guide to setup a Raspberry Pi 4 as a NAS using NFS and Samba    
https://github.com/thagrol/Guides/blob/main/nas.pdf    

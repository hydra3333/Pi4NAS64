# Pi4NAS
### a Raspberry Pi4 NAS for use by "Google ChromeCast with Google TV" devices   

---

## Description <TL;DR> 

Configure a Raspberry Pi4 with attached USB3 drives to create an NAS on our local home LAN with 
- "open" rw NFS file shares   
- "open" rw SAMBA file shares   
- "open" rw ftp server (`proftpd`)   
- a DLNA server (`miniDLNA`)   
- the `hd-idle` app to spin down drives when not used   

The newly released "Google ChromeCast with Google TV" devices can connect to the Pi4NAS 
with apps like `Kodi` and `VLC` in order to play our collections of home media files.    

A Raspbetty Pi 4 is comparatively cheap, has very low power usage, is extremely reliable, and has decent thoughput to handle multiple streams.

"Google ChromeCast with Google TV" : https://store.google.com/au/product/chromecast_google_tv_specs

---

## Assumptions     


1. We have One or perhaps Two USB3 external hard drives full of videos, to attach to the Raspbetty Pi    
   - these USB3 drives must be formatted as NTFS by Windows, and have security set to `Everyone` having `Full Access` to the top level and all subfolders and files
   - first USB3 drive has characteristics:    
     * Drive label `mp4library`    
     * a folder at the root level of the first USB3 drive must be `mp4library` and have security set to `Everyone` having `Full Access` to this folder and all subfolders    
   - second USB3 drive has characteristics:    
     * Drive label `mp4library2`    
     * a folder at the root level of the first USB3 drive must be `mp4library` (same as the first drive) and have security set to `Everyone` having `Full Access` to this folder and all subfolders    

2. We choose to sometimes detach the USB3 drives from the Raspberry Pi4 and temporarily attach them to a Windows 10 PC to copy large media files onto them    
   - as we all know, USB3 file copy speeds will be *much* greater for locally attached drives vs copying cross the network    

3. The Raspberry Pi4 is connected to our home LAN via wired ethernet (we'll turn off bluetooth and WiFi)     
   - as we all know, from actual testing, WiFi is subject to contention which limits bandwidth and this may cause lag/stuttering when playing media on devices accessing the shares    

4. We **must** allocate a fixed IPv4 address for our Pi4, perhaps by assigning it a permanent IPv4 lease in DHCP in our home router   
   -  this is really important

5. "Google ChromeCast with Google TV" devices are ideally connected to our home LAN via wired ethernet    
   - as we all know, from actual test results, WiFi is subject to contention which limits bandwidth and this may cause lag/stuttering when playing media    

6. After setup, the monitor/mouse/keyboard can be disconnected from the Pi4 so as to run "headless"    

7. The Pi4 will *not* perform any *external* network connections outside our home LAN at runtime, other than for normal Raspberry Pi O/S operations and its software updates   

8. We will run the *32-bit* version of Raspberry Pi O/S and apps    
   - as at 2020.11.07, we haven't moved over to the 64-bit version of hd-idle (although eveything else should install/work under 64bit)      

9. Of probable interest, playable .mp4 files are    
   - not interlaced (a `Chromecast Ultra` device will not play them, and probably not the "Google ChromeCast with Google TV" either)    
   - max resolution of `1080p` and having an `SDR` colour scheme (unless we have a `Chromecast Ultra` device, in which case `4K` and `HDR`)
   - ideally encoded with codecs `h.264(avc)/aac` ... or `h.265(hevc)/aac`
   - videos encoded with `hevc/avc` won't play in a Chrome browser, but they *will* cast to and play on a Chromecast device 
     * (... neither type of video plays inside a Pi's Chromium browser, unfortunately) 
   - Google's *probably out-of-date list* of acceptable .mp4 codecs for the `Chromecast Ultra` is at https://developers.google.com/cast/docs/media but as yet we can't find one for the "Google ChromeCast with Google TV"

10. We could try using a Raspberry Pi 3b+ instead of a Pi 4, it would build fine, however 
    - it only has USB2 ports with which to attach the external drives, which may not provide enough bandwidth one needs to deliver uninterrupted streams
    - its "limited" ethernet interface may not provide enough bandwidth one needs to deliver uninterrupted streams

---

## Pre-Installaton stuff which **must** be setup first    

1. Ensure our USB3 drives are *not* yet plugged into the Pi4   

2. Install and configure our Raspberry Pi4 4Gb or 8Gb
   - Install 32-bit Raspberry Pi O/S and configure it to how we like it    
   - its hostname must be short and easy and has no spaces or special characters (it will be used as the website name) ... ideally choose `Pi4NAS`   
   - configure it to boot to GIU and autologin ... it is safe to autologin since the Pi is only visible inside our "secure" home LAN   
   - configure a screen resolution which enables VNC server/client to run properly when headless   
     * in a Terminal, using `sudo raspi-config`, `Advanced` 
     * choose a screen resolution ANYTHING (eg 1920x1080) *other* than "default" so that a framebuffer gets allocated on a Pi4 which magically enables VNC server to run even when a screen is not connected to the HDMI port
   - the GUI should be left to boot and auto start, even in a headless state 

3. Check, perhaps using the GUI menu item `Raspberry Pi Configuration`,
   - "login as user pi" is ticked
   - "wait for network" is unticked
   - "splash screen" is disabled
   - VNC is enabled
   - SSH is enabled
   - GPU memory is 384Mb
   - "localisation" tab is used to check/configure our timezone/locale etc... also set local language to `UTF-8` to avoid issues   

4. If the Pi4 is Wired ethernet (ideally it will be), disable WiFi and BlueTooth on the Pi4
   - edit and add these lines into '/boot/config.txt' (perhaps in a Terminal use `sudo nano /boot/config.txt`) and then reboot the Pi4   
     ```
     dtoverlay=pi3-disable-wifi
     dtoverlay=pi3-disable-bt
     ```

5. Ensure the Pi has a fixed IPv4 address
   - perhaps by using our home router's DHCP facility to recognise the Pi's mac address and provide it with an ongoing fixed IPv4 address
   - ensure the Pi4 is rebooted and the IP address "sticks"
   - then start a Terminal and use `ifconfig` to check the IPv4 address has "stuck"


6. Prepare our USB3 drives before we even go near plugging them into the Pi4
   - plug the drive(s) into a Windows PC 
   - format then as NTFS 
   - set security on the drive itself to `Everyone` having `Full Access`
   - set security on the top level and all subfolders and files to `Everyone` having `Full Access`
     * hint: one may need to change "inherited permissions"
   - first USB3 drive has characteristics:    
     * Drive label `mp4library`    
     * a folder at the root level of the first USB3 drive must be `mp4library` and have security set to `Everyone` having `Full Access` to this folder and all subfolders and files    
   - (if one has one) second USB3 drive has characteristics:    
     * Drive label `mp4library2`    
     * a folder at the root level of the first USB3 drive must be `mp4library` (same as the first drive) and have security set to `Everyone` having `Full Access` to this folder and all subfolders and files 
   - copy media files into the folder tree one created, and check security permissikons on them is set correctly	 

6. Cross-check **eveything** and Reboot the Pi4 one last time to ensure all settings are good

---

## Install the NAS related apps into the Pi4    

1. Re-check that the Pi4 has been pre-configured correctly, particularly the server-name and fixed IPv4 address    

2. Prepare our USB3 drives on the Pi4
   - plug the USB3 external hard drive(s) into the Pi4 (always use the same drives in the same USB3 slots !)
   - wait 15 to 30 seconds for the USB3 external hard drives to spin up and be mounted automatically
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

3. Clone the Pi4NAS Github respository to the Desktop of the Pi and copy the setup files to the Desktop
   - start a Terminal and do this:
     ```
     cd ~/Desktop
     sudo apt install -y git
     sudo rm -vfR ./Pi4NAS
     git clone https://github.com/hydra3333/Pi4NAS.git
     cp -fv ./Pi4NAS/*.sh ./
     sudo chmod +777 *.sh
	 # check the uid and gid for user pi 
	 id -u pi
	 id -g pi
	 echo "uid=$(id -r -u pi) gid=$(id -r -g pi)" 
     ```

4. Now, start a Terminal and start the install/configure process:
     ```
     cd ~/Desktop
     chmod +777 *.sh
     ./setupNAS.sh 2>&1 | tee setupNAS.log
     ```
5. Answer the prompts (it will save most of these answers for use later)
   - `This server_name` it's best to choose the Pi4's hostname of the Pi4 here (we use Pi4NAS) - it will be used as the network service name by `Kodi` and `VLC` etc
   - `This server_alias (will become a Virtual Folder for mounting purposes)` - recommend leave it as `mp4library` so it matches the top level folder name on the USB3 drive
     * ... it will be used as the top-level folder name on our external USB3 drive, so put our video files in there
   - `Designate the mount point for the USB3 external hard drive` it's a "virtual" place used everywhere to access the top level of the USB3 external hard drive when mounted, eg `/mnt/mp4library`
   - `Designate the root folder on the USB3 external hard drive` it's the top level folder on the USB3 external hard drive containing .mp4 files and subfolders containing .mp4 files, eg `/mnt/mp4library/mp4library`

6. Answer more prompts    
   - when we see something like this:
     ```
     Before we start the server, we’ll want to set a Samba password. Enter we pi password.
     + sudo smbpasswd -a pi
     New SMB password:
     ```
     enter the password we had set for the pi login,    
     then enter it again when we see `Retype new SMB password:`    
   - then when we see something like this,    
     ```
     Before we start the server, we’ll want to set a Samba password. Enter we pi password.
     + sudo smbpasswd -a root
     New SMB password:
     ```
     enter the password we had set for the pi login,    
     then enter it when we see `Retype new SMB password:`    

7. Answer more prompts    
   - sometimes we will be asked to visually scan and check setup results for issues, and to press Enter to continue

8. When the process completes, Reboot the Pi4 so that the new settings take effect

---

## Also see ...

How to setup a Raspberry Pi 4 as a NAS using NFS with an external USB3 disk    
https://www.raspberrypi.org/forums/viewtopic.php?f=91&t=289118&p=1751528#p1751528    

How to setup a Raspberry Pi 4 as a NAS using SAMBA with an external USB3 disk    
https://www.raspberrypi.org/forums/viewtopic.php?f=91&t=289943    

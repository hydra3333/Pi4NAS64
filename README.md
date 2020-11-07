# UNDER CONSTRUCTION

# Pi4NAS
### a Raspberry Pi4 NAS for use by "Google ChromeCast with Google TV" devices   

## Description <TL;DR> 

Configure a Raspberry Pi4 with attached USB3 disks to create an NAS on our local home LAN with 
- "open" rw NFS file shares   
- "open" rw SAMBA file shares   
- "open" rw ftp server   
- a DLNA server   
- the `hd-idle` app to spin down disks when not used   

It can be connected to by the newly released "Google ChromeCast with Google TV" devices with 
apps `Kodi` and `VLC` in order to play our collection of home media files.    

A Raspbetty Pi 4 is comparatively cheap, very low power, extremely reliable, and has decent thoughput to handle multiple streams.

"Google ChromeCast with Google TV" : https://store.google.com/au/product/chromecast_google_tv_specs

---

## Assumptions     


1. We have One or perhaps Two USB3 external hard drives full of videos, to attach to the Raspbetty Pi    
   - these USB3 drives must be formatted as NTFS by Windows, and have security set to `Everyone` gaving `Full Access` to the top level and all subfolders
   - first USB3 drive has characteristics:    
   * Drive label `mp4library`    
   * a folder at the root level of the first USB3 drive must be `mp4library` and have security set to `Everyone` gaving `Full Access` to this folder and all subfolders    
   - second USB3 drive has characteristics:    
   * Drive label `mp4library2`    
   * a folder at the root level of the first USB3 drive must be `mp4library` (same as the first drive) and have security set to `Everyone` gaving `Full Access` to this folder and all subfolders    

2. We choose to sometimes detach the USB3 drives from the Raspberry Pi4 and temporarily attach them to a Windows 10 PC to copy large media files onto them    
   - as we all know, USB3 file copy speeds will be *much* greater for locally attached disks vs copying cross the network    

3. The Raspberry Pi4 is connected to our home LAN via wired ethernet (we'll turn off bluetooth and WiFi)     
   - as we all know, from actual testing, WiFi is subject to contention which limits bandwidth and this may cause lag/stuttering when playing media on devices accessing the shares    

4. We **must** allocate a fixed IPv4 address for our Pi4, perhaps by assigning it a permanent IPv4 lease in DHCP in our home router    

5. "Google ChromeCast with Google TV" devices are ideally connected to our home LAN via wired ethernet    
   - as we all know, from actual test results, WiFi is subject to contention which limits bandwidth and this may cause lag/stuttering when playing media    

6. After setup, the monitor/mouse/keyboard can be disconnected from the Pi4 so as to run "headless"    

7. The Pi4 will *NOT* perform any *external* network connections outside our home LAN at runtime, other than for normal Raspberry Pi O/S operations and its software updates   

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

## Pre-Installaton stuff which must setup first    

1. Ensure our USB3 disks are *not* yet plugged into the Pi4   

2. Install and configure our Raspberry Pi4 4Gb or 8Gb
   - Install 32-bit Raspberry Pi O/S and configure it to how we like it    
   - its hostname must be short and easy and has no spaces or special characters (it will be used as the website name) ... ideally choose `Pi4NAS`   
   - configure it to boot to GIU and autologin ... it is safe to autologin since the Pi is only visible inside our "secure" home LAN   
   - configure a screen resolution which enables VNC server/client to run properly when headless   
     * in a Terminal, using sudo raspi-config, Advanced 
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

4. Ensure the Pi has a fixed IPv4 address
   - perhaps by using our home router's DHCP facility to recognise the Pi's mac address and provide it with an ongoing fixed IPv4 address

5. If the Pi4 is Wired ethernet (ideally it will be), disable WiFi and BlueTooth on the Pi4
   - add these lines into '/boot/config.txt' and reboot the Pi4   
     ```
     dtoverlay=pi3-disable-wifi
     dtoverlay=pi3-disable-bt
     ```
6. Prepare our USB3 disks
   - plug the USB3 external hard drive(s) in to the Pi4 (always use the same drives in the same USB3 slots !)
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

7. Clone the Pi4NAS Github respository to the Desktop of the Pi and copy the setup files to the Desktop
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

8. Now, start a Terminal and start the intall/configure process:
     ```
     cd ~/Desktop
     chmod +777 *.sh
     ./setupNAS.sh
     ```
   - answer initial prompts (it will save these answers for use later)
     * `This server_name` it's best to enter the hostname of the Pi here (I use Pi4NAS), it will be used as the Apache2 website name
     * `This server_alias (will become a Virtual Folder within the website)` recommend leave it as `mp4library` 
	 ... it will be used as the top-level folder name on our external USB3 hard drive, so put our video files there
     * `Designate the mount point for the USB3 external hard drive` it's a "virtual" place used everywhere to access the top level of the USB3 external hard drive when mounted, eg `/mnt/mp4library`
     * `Designate the root folder on the USB3 external hard drive` it's the top level folder on the USB3 external hard drive containing .mp4 files and subfolders containing .mp4 files, eg `/mnt/mp4library/mp4library`
   - answer other prompts
     * sometimes we will be asked to visually scan setup results for issues, and press Enter to continue
   - Reboot the Pi so that any new settings take effect

   
   
   
---
# under construction

under here is stuff used for editing into the text above

   
7. After rebooting, do part "Setup 1" of the installation (it should be re-startable, feel free to "Control C" and re-start if we feel uncomfortable)
   - In a Terminal and do this:
     ```
     cd ~/Desktop
     chmod +777 *.sh
     ./setup_1.0.sh
     ```
   - this will be a longish process (15 to 30 mins) with a number of prompts
   - answer initial prompts (it will remember the answers we gave in `setup_0.0.sh` as defaults ... don't change them now !)
   - answer other prompts
     * sometimes we will be asked to visually scan setup results for issues, and press Enter to continue
     * observe progress and USE "control C" if we spot anything "unfortunate" occurring
     * when we see something like this (I cannot seem to avoid it prompting)
       ```
       + sudo openssl pkcs12 -export -out /etc/tls/localcerts/PiDesktop.pfx -inkey /etc/tls/localcerts/PiDesktop.key.orig -in /etc/tls/localcerts/PiDesktop.pem
       Enter Export Password:
       ```
       just press Enter, then press Enter again to the next prompt `Verifying - Enter Export Password:`
     * when we see something like this,
       ```
       # apache user, 'pi' ... Enter our normal password, then again
       + sudo htpasswd -c /usr/local/etc/apache_passwd pi
       New password: 
       ```
       enter the password we had set for the pi login, then enter it again when we see `Re-type new password:`
     * when we see something like this,
       ```
       Before we start the server, we’ll want to set a Samba password. Enter we pi password.
       + sudo smbpasswd -a pi
       New SMB password:
       ```
       enter the password we had set for the pi login, then enter it again when we see `Retype new SMB password:`
     * then when we see something like this,
       ```
       Before we start the server, we’ll want to set a Samba password. Enter we pi password.
       + sudo smbpasswd -a root
       New SMB password:
       ```
       enter the password we had set for the pi login, then enter it again when we see `Retype new SMB password:`
8. After rebooting now, it's ready.
   - try to connect to it from a PC or tablet using a Chrome browser,
     (where Pi4NAS below is the hostname of the Pi and xx.xx.xx.xx is the fixed IPv4 address of the Pi)
     ```
     https://xx.xx.xx.xx/Pi4NAS
     https://xx.xx.xx.xx/mp4library
     ```
     on the Pi itself, we can try the Chromium browser to at least see if it works
     (where Pi4NAS below is the hostname of the Pi and xx.xx.xx.xx is the fixed IPv4 address of the Pi)
     ```
     https://xx.xx.xx.xx/Pi4NAS
     https://xx.xx.xx.xx/mp4library
     ```
     * **Please note:** 
       * we won't be able to play a video in the Pi browser itself, but we can click on the `triangle` expander to see if it works
       * videos encoded with `hevc/avc` won't play in a Chrome browser, likely something to do with google and licensing of `hevc`
       * only a google Chrome browser on a PC or tablet works to cast videos from the website to a Chromecast device
   - we **WILL** see a Chrome message `our connection is not private ... etc etc` which is due to 
     us using our (free) self-signed SSL/TLS certificate rather than a paid-for one (which has other associated complexities)
     * to accept this, click on the button `Advanced`
     * then click on the link which says `Proceed to xx.xx.xx.xx (unsafe)` (it be showing the hostname of the Pi)
     * the browser should remember this is OK, and proceed to display the Pi's new website
   - we can now disconnect the Pi from the monitor, keyboard, and mouse, if we want to make it headless   
     - yes, the GUI should be left running and left to start at boot time, so we can VNC into it later from our PC






# motionPie #

## About #

**motionPie** is a Linux distribution that turns your [Raspberry PI](http://www.raspberrypi.org/) into a video surveillance system. The OS is based on [BuildRoot](http://buildroot.uclibc.org/) (credits go to Guillermo A. Amaral for [adapting BuildRoot to the Raspberry PI](https://github.com/gamaral/rpi-buildroot)).

**motionPie** uses [motion](http://www.lavrsen.dk/foswiki/bin/view/Motion/WebHome) as a backend and [motionEye](https://bitbucket.org/ccrisan/motioneye/) for the frontend.

Check this [link](https://bitbucket.org/ccrisan/motioneye/wiki/Screenshots) for some screenshots.

## Features ##

* easy setup (see Install Instructions below)
* **web-based**, mobile/tablet-friendly user interface
* compatible with most **USB cameras** as well as with the Raspberry PI camera module
* support for **IP cameras**
* **motion detection** with email notifications and working schedule
* **JPEG** files for still images, **AVI** files for videos
* **timelapse** movies
* connects to the network using **ethernet** or **wifi**
* file storage on **SD card**, **USB drive** or **network SMB share**
* media files are visible in the local network as **SMB shares**
* media files can also be accessed through the built-in **FTP server**  or **SFTP server**

## Hardware Requirements ##

* a Raspberry PI (any model and revision should be fine)
* a USB camera or a Raspberry PI camera module
* a micro-usb power supply capable of at least 1A (if your USB devices are power-hungry, consider using a powered USB hub)
* an SD card (any capacity will do, as the OS itself requires less than 200M)
* optionally, a USB wifi adapter if an ethernet connection is not possible
* optionally, a USB drive for storing files

## Installation Instructions ##

### Stable Version ###

All releases are available from [here](https://github.com/ccrisan/motionPie/releases) and are marked by date.

1. download the latest stable release (called `motionPie-YYYYmmdd.img.gz`)
2. extract the image file called `motionPie.img` from the archive
3. write the image file to your SD card:

    **If you run Linux or OSX**, there's a [writeimage.sh](https://raw.githubusercontent.com/ccrisan/motionPie/master/board/raspberrypi/writeimage.sh) script that will do everything for you, including the setup of a wireless network connection. Just run the script as follows (replacing the arguments with appropriate values):
    
        ./writeimage.sh -d /dev/mmcblk0 -i /path/to/motionPie.img -n yournet:yourkey
        
   Optionally you can give other arguments to `writeimage.sh` to configure various features of your system. Here's a full list of available arguments:

* `<-i image_file>` - indicates the path to the image file (e.g. `-i /home/user/Download/motionPie.img`)
* `<-d sdcard_dev>` - indicates the path to the sdcard block device (e.g. `-d /dev/mmcblk0`)
* `[-a off|public|auth|writable]` - configures the internal samba server (e.g. `-a auth`)
    * default - shares are read-only, no authentication required
    * `off` - samba server disabled
    * `public` - shares are read-only, no authentication required
    * `auth` - shares are read-only, authentication required
    * `writable` - shares are writable, authentication required
* `[-f off|public|auth|writable]` - configures the internal ftp server (e.g. `-f auth`)
    * default - read-only mode, anonymous logins
    * `off` - ftp server disabled
    * `public` - read-only mode, anonymous logins
    * `auth` - read-only mode, authentication required
    * `writable` - writable mode, authentication required
* `[-h off|on]` - configures the internal ssh server (e.g. `-h on`)
    * default - ssh server enabled
    * `off` - ssh server disabled
    * `on` - ssh server enabled
* `[-l]` - disables the LED on the CSI camera module
* `[-n ssid:psk]` - sets the wireless network name and key (e.g. `-n mynet:mykey1234`)
* `[-o none|modest|medium|high|turbo]` - overclocks the PI according to a preset (e.g. `-o high`)
    * default - arm=900Mhz, core=500Mhz, sdram=500MHz, ov=6
    * `none` - arm=700Mhz, core=250Mhz, sdram=400MHz, ov=0
    * `modest` - arm=800Mhz, core=250Mhz, sdram=400MHz, ov=0
    * `medium` - arm=900Mhz, core=250Mhz, sdram=450MHz, ov=2
    * `high` - arm=950Mhz, core=250Mhz, sdram=450MHz, ov=6
    * `turbo` - arm=1000Mhz, core=500Mhz, sdram=600MHz, ov=6
* `[-p port]` - listen on the given port rather than on 80 (e.g. `-p 8080`)
* `[-s ip/cidr:gw:dns]` - sets a static IP configuration instead of DHCP (e.g. `-s 192.168.3.107/24:192.168.3.1:8.8.8.8`)
* `[-w]` - disables rebooting when the network connection is lost

    **If you don't know how to write an OS image to an SD card**, just follow [these instructions](http://www.raspberrypi.org/documentation/installation/installing-images/README.md). System customizations are not available when using these methods.

### Latest GIT Version ###

Although not recommended, you may want to compile the latest GIT version. You need a computer running Linux to do this. Here are the steps to download, compile and prepare the image from the GIT repo:

1. make sure your system meets the [Buildboot requirements](http://buildroot.uclibc.org/downloads/manual/manual.html#requirement)
2. clone the repository:
    
        git clone --depth 1 https://github.com/ccrisan/motionPie.git

3. use the default configuration:

        make motionpie_defconfig

4. compile everything (don't use `-j`):

        make

5. prepare your image file (will invoke sudo):

        board/raspberrypi/mkimage.sh
    
    You can use the `mkimage.sh` script to obtain a compressed image (using `-c`), to preconfigure the wireless network (using `-n`) and to write the image directly to your SD card (using `-d`). See `mkimage.sh -h` for more details.
    
    If everything worked well, you will find your freshly built image at `output/images/motionPie.img[.gz]`.

6. write the image file to your SD card using `dd` (replacing `/dev/mmcblk0` with your SD card reader device):

        sudo dd if=output/images/motionPie.img of=/dev/mmcblk0 bs=1M

### First Boot ###

When booting a fresh image installation, a few initialization steps will take place and therefore the system won't be ready for about 1-2 minutes. These steps are:

* preparing the data partition on the SD card
* configuring SSH remote access
* setting the default root password for remote login (to the PI's serial number)
* auto-configuring any installed video devices

As soon as your motionPie is ready it will listen on port 80 and present you with a web user interface. Click on the key icon on the upper left side of the page to *switch user* to admin. Use `admin` with no password when asked for credentials.

Of course your motionPie needs an IP address before you can communicate with it so you'll have to use the ethernet connection with DHCP enabled, at least for the first configuration.

## Configuration ##

The web user interface allows you to configure pretty much everything. You'll probably want to enable the advanced settings option. Here are the most important things you should take care of when configuring your motionPie for the first time:

* set a password for the two users (`admin` and `user`)
* set the correct timezone for your region
* enable the wireless connection, if you have one
* configure your video device(s) (resolution, framerate etc)
* configure the file storage if you want your pictures/movies saved on a network or USB drive
* enable still images and/or motion movies if you want any information to be recorded

The installed video devices are normally automatically detected and configured for you, but you can however add more devices (including remote devices) from the settings panel.

If you know your way around Linux and you wish to tweak advanced settings you'll find a few configuration files on the third partition of the SD card, in the folder `etc`. You'll probably find `motion.conf`, `thread-x.conf` and `wpa_supplicant.conf` of interest.

## Normal Use ##

There are two users that can be used to access the web interface: `admin` and `user`. The former is meant for administrative purposes while the later should be used for surveillance.

Most modern browsers, including the mobile ones, should work fine with the web interface. Just point your browser to the IP address of your motionPie (on port 80) and enter your credentials. The cameras will automatically refresh according to their configured streaming refresh rate. You can click on any of them to display it alone or you can use the *full screen* button of each camera to open a full window/tab displaying only that camera.

Movies and pictures taken by each camera can be browsed, previewed and downloaded using the media browser window which opens by clicking on the *pictures* or *movies* buttons.

These pictures and movies recored by motionPie are visible on the local network as well. Just look for your motionPie in your network in a Windows Explorer window or use the `smb://your_motion_pie/` URL if on Linux. The two shares, `sdcard` and `storage` represent the local SD card data partition and any other attached storage, respectively.

If you wish to access your files through FTP, you can do so. Unless you have tweaked your system otherwise, FTP anonymous logins are enabled and your media files can be downloaded using virtually any FTP client.

## Troubleshooting ##

### No User Interface On Monitor ###

motionPie will never display anything useful on your monitor. It is meant to only be used from a web browser. The ugly text that appears on the monitor is actually useful when debugging motionPie. Most users should ignore it.

### Raspberry PI Model A ###

*Model A* has no wired ethernet connector and thus it's impossible to access it unless it is connected to a wireless network. To preconfigure the wireless network for a Model A you must use `writeimage.sh` with the `-n ssid:psk` argument.

### System Rebooting ###

The system will reboot whenever something goes wrong (i.e. disconnected from network, software hangs or kernel crashes). This is accomplished using the hardware watchdog as well as software watch scripts. It is therefore possible that the system enter an indefinite reboot loop if, for example, the network is misconfigured. Invoking `writeimage.sh` with `-w` when writing the image disables rebooting when wireless connection issues are encountered.

### Date & Time ###

NTP is used to synchronize the system time, so an Internet connection is required. Initial date is set upon each boot and uses HTTP instead of NTP for faster boot. The local time is established by the time zone setting in the web UI.

### Shell Access ###

If you connect a monitor and a keyboard to your PI, you'll be prompted to login in the text console. `root` is the username and the password is your administrator's password that you had configured in the UI. If you haven't configured it (i.e. you left it empty), the password is the serial number of your PI unit. Don't worry, the serial number is part of motionPie's hostname and will appear as part of the welcome banner when you're prompted for a password.

You can also log into your motionPie using ssh or putty. It listens on the standard 22 port, unless you tweaked the system otherwise.

As an alternative, you can log in on the serial port of your PI. Just connect it to your PC's serial port and use your favorite serial terminal program to log in. The serial port is configured as 115200 8N1.

## Tweaks ##

### Partition Layout ###

motionPie uses three partitions:

	1. a boot partition, FAT32, about 16M, mounted read-only at /boot
	2. a root partition, EXT4, about 120M, mounted read-only at /
	3. a data partition, EXT4, fills up the entire remaining card space, mounted read-wrtie at /data
	
The *boot* and *root* partitions are both overwritten when performing an update (except for the `/boot/config.txt` file which is preserved). Whenever you need to change something on either *root* or *boot* partitions, run the following command to make them writable:

	mount -o remount,rw /
	mount -o remount,rw /boot

The *data* partition contains all the configuration files as well as media files (recorded movies and pictures taken). It is created and formatted at first boot. Wiping out the *data* partition is equivalent to a *factory reset*.

### Manually Editing Network Configuration ###

There's no `/etc/network/interfaces` file. Networking is configured by `/etc/init.d/S35wifi` and `/etc/init.d/S40network`.

The wifi script looks for `/data/etc/wpa_supplicant.conf`; if found, it's used to establish the wifi connection. If this file is absent, it looks for `/etc/wpa_supplicant.conf` (normally created by `writeimage.sh`) and it copies it over to `/data/etc/`, using it thereafter. If none of the files are present, wifi connection is skipped.

The network script looks for `/data/etc/static_ip.conf`; if found, it's used for configuring the IP of the *first* connected interface (`wlan0`, `eth0` in this order). If this file is absent, it looks for `/etc/static_ip.conf` (normally created by `writeimage.sh`) and it copies it over to `/data/etc`, using it thereafter.. If none of the files are present, all the connected interfaces are configured using *DHCP*.

Here's an example of a `static_ip.conf` file:

	static_ip="192.168.0.3/24"
	static_gw="192.168.0.1"
	static_dns="8.8.8.8"

### Tweaking motionEye ###

motionEye is installed at `/programs/motioneye`, on the *root* partition. After remounting the root partition read-write, you can edit `/programs/motioneye/settings.py` and its startup script, `/etc/init.d/S95motioneye`.


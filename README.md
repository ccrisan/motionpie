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
* connects to the network using **ethernet** or **wifi**
* file storage on **SD card**, **USB drive** or **network SMB share**
* files on SD card visible in the local network as a **SMB share**

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

    **If you run Linux**, there's a [writeimage.sh](https://github.com/ccrisan/motionPie/blob/master/board/raspberrypi/writeimage.sh) script that will do everything for you, including the setup of a wireless network connection. Just run the script as follows (replacing the arguments with appropriate values):
    
        ./writeimage.sh -d /dev/mmcblk0 -i /path/to/motionPie.img -n yournet:yourkey

    **If you don't know how to do it**, just follow [these instructions](http://www.raspberrypi.org/documentation/installation/installing-images/README.md).

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

As soon as your motionPie is ready it will listen on port 80 and present you with a web user interface. Use `admin` with no password when asked for credentials.

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

## Troubleshooting ##

### Stuck With Rainbow On Display ###

MotionPie has no video driver compiled in and therefore it won't control your display in any way. The rainbow you see is what PI's GPU shows by default when powered on. Nevertheless things happen in the background and your motionPie should be up and running (i.e. listening on port 80) in less than 2 minutes.

### System Rebooting ###

The system will reboot whenever something goes wrong (i.e. disconnected from network, software hangs or kernel crashes). This is accomplished using the hardware watchdog as well as software watch scripts. It is therefore possible that the system enter an indefinite reboot loop if, for example, the network is misconfigured.

### Date & Time ###

NTP is used to synchronize the system time, so an Internet connection is required. The local time is established by the time zone setting in the web UI.

### Remote Shell ###

You can log into your motionPie using SSH. It listens on the standard 22 port. The only enabled user is `root` and the password is the serial number of your PI unit. Don't worry, the serial number is part of motionPie's hostname and will appear as part of the welcome banner when you're asked for a password.

The SD card has 3 partitions, as follows:
* the boot partition, mounted at `/boot`, read-only
* the root partition, mounted at `/`, read-only
* the data partition, mounted at `/data`, writable

If you want to make changes on any of the read-only partitions, you need to mount them read-write first. For example:

    mount -o remount,rw /

If you want to dig deeper you can log in on the serial port of your PI. Just connect it to your PC's serial port and use your favorite serial terminal program to log in or simply watch the output of the system. The serial port is configured as 115200 8N1.


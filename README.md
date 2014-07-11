# motionPie #

## About #

**motionPie** is a Linux distribution that turns your [Raspberry PI](http://www.raspberrypi.org/) into a video surveillance system. The OS is based on [BuildRoot](http://buildroot.uclibc.org/) (credits go to Guillermo A. Amaral for [adapting BuildRoot to the Raspberry PI](https://github.com/gamaral/rpi-buildroot)).

**motionPie** uses [motion](http://www.lavrsen.dk/foswiki/bin/view/Motion/WebHome) as a backend and [motionEye](https://bitbucket.org/ccrisan/motioneye/) for the frontend.

## Features ##

* easy setup (see Install Instructions below)
* **web-based**, mobile/tablet-friendly user interface
* compatible with most **USB cameras** as well as with the Raspberry PI camera module
* motion detection
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
3. write the image file to your SD card (follow [these instructions](http://www.raspberrypi.org/documentation/installation/installing-images/README.md) if you don't know how)

### Latest GIT Version ###

Although not recommended, you may want to compile the latest GIT version. You need a computer running Linux to do this. Here are the steps to download, compile and prepare the image from the GIT repo:

1. make sure your system meets the [Buildboot requirements](http://buildroot.uclibc.org/downloads/manual/manual.html#requirement)
2. clone the repository:
    
        git clone --depth 1 https://github.com/ccrisan/motionPie.git

3. use the default configuration:

        make defconfig

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

### Normal Use ###

* web UI port 80
* admin/surveillance user
* samba

## Troubleshooting ##

* watchdogs
* ntp


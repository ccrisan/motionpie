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

## Install Instructions ##

### Stable Version ###

Stable releases are available from [here](https://github.com/ccrisan/motionPie/releases) and are marked date.

* step 1: download the latest archive (either zip or tar.gz)
* step 2: extract the archive
* step 3: copy the extracted image file to your SD card

### Latest GIT Version ###

## How It Works ##

### First Boot ###

* ssh
* password
* auto config of video devices
* longer duration

### Normal Boot ###

* ntp
* samba
* watchdogs
* port 80

## Configuration ##

## Troubleshooting ##


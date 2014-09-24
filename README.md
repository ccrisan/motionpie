Buildroot for Raspberry Pi
==========================

This buildroot fork will produce a very light-weight and trimmed down
toolchain, rootfs and kernel for the Raspberry Pi. It's intended for **advanced
users** and specific embedded applications.

Before You Begin
----------------

- If you're not familiar with Buildroot and what it can and can't do, please
  take the time to [read the manual](http://buildroot.org/downloads/manual/manual.html).

- You must be pretty comfortable with **cross-compilation** in order to use
  rpi-buildroot.

Test Drive
----------

You can test drive rpi-buildroot by following the instructions below:

	wget http://dl.guillermoamaral.com/rpi/sdcard.img.xz
	xz -d sdcard.img.xz
	sudo dd if=sdcard.img of=/dev/sdx # replace *sdx* with your actual sdcard device node

The default user is **root**, no password will be requested.

### Toolchain

I've added a x86 64-bit toolchain, it has everything needed to cross-compile software for
use with the test-drive image, download and usage instructions below:

	wget http://dl.guillermoamaral.com/rpi/rpi-buildroot-toolchain.tar.xz
	tar -xvJf rpi-buildroot-toolchain.tar.xz
	source rpi-buildroot-toolchain-x86_64/env
	$CC -I"${BUILDROOT_STAGING_DIR}/usr/include" \
	    -I"${BUILDROOT_STAGING_DIR}/opt/vc/include" \
	    -L"${BUILDROOT_STAGING_DIR}/opt/vc/lib" \
	    -L"${BUILDROOT_STAGING_DIR}/usr/lib" \
	    -L"${BUILDROOT_STAGING_DIR}/lib" \
	    -L"${BUILDROOT_TARGET_DIR}/opt/vc/lib" \
	    -L"${BUILDROOT_TARGET_DIR}/usr/lib" \
	    -L"${BUILDROOT_TARGET_DIR}/lib" \
	    main.c # example usage

If you're interested in using the toolchain with CMake, you may want to
download the toolchain cmake file used with Marshmallow Game Engine:

	wget https://github.com/gamaral/marshmallow_h/blob/master/cmake/Toolchain-buildroot.cmake
	# The **env** file needs to be **sourced** before executing the following command
	cmake -DCMAKE_TOOLCHAIN_FILE=Toolchain-buildroot.cmake .
	make

Building
--------

	git clone --depth 1 git://github.com/gamaral/rpi-buildroot.git
	cd rpi-buildroot
	make raspberrypi_defconfig
	make nconfig         # if you want to add packages or fiddle around with it
	make                 # build (NOTICE: Don't use the **-j** switch, it's set to auto-detect)

Deploying
---------

### Script

I've added a script that can automatically flash your sdcard, you simply need
to point it to the correct device node, confirm and you're done!

**Notice** you will need to replace *sdx* in the following commands with the
actual device node for your sdcard.

    # run the following as root (sudo)
    board/raspberrypi/mksdcard /dev/sdx

### Manual

You will need to create two partitions in your sdcard, the first (boot) needs
to be a small *W95 FAT16 (LBA)* patition (that's partition id **e**), about 32
MB will do.

**Notice** you will need to replace *sdx* in the following commands with the
actual device node for your sdcard.

Create the partitions on the SD card. Run the following as root.
**Notice** all data on the SD card will be lost.

	fdisk /dev/sdx
	> p             # prints partition table
	> d             # repeat until all partitions are deleted
	> n             # create a new partition
	> p             # create primary
	> 1             # make it the first partition
	> <enter>       # use the default sector
	> +32M          # create a boot partition with 32MB of space
	> n             # create rootfs partition
	> p
	> 2
	> <enter>
	> <enter>       # fill the remaining disk, adjust size to fit your needs
	> p             # double check everything looks right
	> w             # write partition table to disk.

Now format the boot partition as FAT 16

	# run the following as root
	mkfs.vfat -F16 -n boot /dev/sdx1
	mkdir -p /media/boot
	mount /dev/sdx1 /media/boot

You will need to copy all the files in *output/images/boot* to your *boot*
partition.

	# run the following as root
	cp output/images/boot/* /media/boot
	umount /media/boot

The second (rootfs) can be as big as you want, but with a 200 MB minimum,
and formated as *ext4*.

	# run the following as root
	mkfs.ext4 -L rootfs /dev/sdx2
	mkdir -p /media/rootfs
	mount /dev/sdx2 /media/rootfs

You will need to extract *output/images/rootfs.tar* onto the partition, as **root**.

	# run the following as root
	tar -xvpsf output/images/rootfs.tar -C /media/rootfs # replace with your mount directory
	umount /media/rootfs


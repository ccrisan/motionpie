BuildRoot for Raspberry Pi
==========================

This buildroot fork will produce a very light-weight and trimmed down
toolchain, rootfs and kernel for the Raspberry Pi. It's intended for advanced
users and specific embedded applications.

The default configuration is trimmed down but still contains a few
applications to help with development and testing, it should be trimmed down
further and secured before actual field deployment.

Test Drive
----------

You can test drive rpi-buildroot by following the instructions below:

	wget http://dl.guillermoamaral.com/rpi/sdcard.img.xz
	xz -d sdcard.img.xz
	sudo dd if=sdcard.img of=/dev/sdx # replace *sdx* with your actual sdcard device node

The default user is **root**, no password will be requested.

### Toolchain

I've added a toolchain, it has everything needed to cross-compile software for
use with the test-drive image, download and usage instructions below:

	wget http://dl.guillermoamaral.com/rpi/rpi-buildroot-toolchain.tar.xz
	tar -xvJf rpi-buildroot-toolchain.tar.xz
	source rpi-buildroot-toolchain/env
	$CC -I"${BUILDROOT_HOST_DIR}/usr/include" \
	    -I"${BUILDROOT_STAGING_DIR}/usr/include" \
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

Updating
--------

Since I keep this overlay fork rebased to buildroot master, you will need to
replace your local branch completely:

	git fetch origin
	git checkout origin/rpi
	git checkout -B rpi

I added a little helper script to the base directory that can do the legwork:

	./rpi-buildroot-update.sh

Deploying
---------

You will need to create two partitions in your sdcard, the first (boot) needs
to be a small *W95 FAT32 (LBA)* patition (that's partition id **c**), about 50
MB will do.

**Notice** you will need to replace *sdx* in the following commands with the
actual device node for your sdcard.

	# run the following as root
	mkfs.vfat -F 32 -n boot /dev/sdx1
	mkdir -p /media/boot
	mount /dev/sdx1 /media/boot

You will need to copy all the files in *output/target/boot* to your *boot*
partition.

	# run the following as root
	cp output/target/boot/* /media/boot
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


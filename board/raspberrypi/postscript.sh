#!/bin/sh

TARGET="$1"
RPI_DIR=$(dirname $0)

# copy System.map
cp $TARGET/../build/linux-*/System.map $TARGET/System.map

# copy kernel
cp $TARGET/../images/zImage $TARGET/../images/boot/kernel.img

# custom rpi config
cp $RPI_DIR/config.txt $TARGET/../images/boot/config.txt
cp $RPI_DIR/cmdline.txt $TARGET/../images/boot/cmdline.txt

# disable startup scripts
rm -f $TARGET/etc/init.d/S15watchdog # replaced by S98watchdog
rm -f $TARGET/etc/init.d/S49ntp # replaced by S60ntp
rm -f $TARGET/etc/init.d/S20urandom

exit 0


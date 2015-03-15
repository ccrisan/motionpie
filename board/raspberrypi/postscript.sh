#!/bin/sh

export TARGET="$1"
export BOARD=$(dirname $0)
export COMMON=$BOARD/../common

# copy System.map
cp $TARGET/../build/linux-*/System.map $TARGET/System.map

# boot
BOOT=$TARGET/../images/boot/
RPI_FW=$TARGET/../images/rpi-firmware

mkdir -p $BOOT

cp $BOARD/config.txt $BOOT
cp $BOARD/cmdline.txt $BOOT
cp $BOARD/fwupdater.gz $BOOT
cp $TARGET/../images/zImage $BOOT/kernel.img
cp $RPI_FW/bootcode.bin $BOOT
cp $RPI_FW/start.elf $BOOT
cp $RPI_FW/fixup.dat $BOOT

$COMMON/startup-scripts.sh
$COMMON/cleanups.sh

rm -rf $TARGET/opt/vc/src
rm -rf $TARGET/opt/vc/include


#!/bin/sh

TARGET="$1"
BOARD=$(dirname $0)
COMMON=$BOARD/../common

# copy System.map
cp $TARGET/../build/linux-*/System.map $TARGET/System.map

# boot directory
mkdir -p $TARGET/../images/boot/
cp $TARGET/../images/uImage $TARGET/../images/boot/
cp $TARGET/../images/script.bin $TARGET/../images/boot/
#cp $TARGET/../images/sun7i-a20-bananapi.dtb $TARGET/../images/boot/
mkimage -C none -A arm -T script -d $BOARD/boot.cmd $TARGET/../images/boot/boot.scr

$COMMON/startup-scripts.sh
$COMMON/cleanups.sh

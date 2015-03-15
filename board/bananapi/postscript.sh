#!/bin/sh

export TARGET="$1"
export BOARD=$(dirname $0)
export COMMON=$BOARD/../common

# copy System.map
cp $TARGET/../build/linux-*/System.map $TARGET/System.map

# boot directory
mkdir -p $TARGET/../images/boot/
cp $TARGET/../images/uImage $TARGET/../images/boot/
cp $TARGET/../images/script.bin $TARGET/../images/boot/
#cp $TARGET/../images/sun7i-a20-bananapi.dtb $TARGET/../images/boot/
mkimage -C none -A arm -T script -d $BOARD/boot.cmd $TARGET/../images/boot/boot.scr

# disable software updating
sed -i 's/enable_update=True/enable_update=False/' $TARGET/programs/motioneye/src/handlers.py

$COMMON/startup-scripts.sh
$COMMON/cleanups.sh

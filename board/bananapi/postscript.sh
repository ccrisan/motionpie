#!/bin/sh

export TARGET="$1"
export BOARD=$(basename $0)

BOARD_DIR=$(dirname $0)
COMMON_DIR=$BOARD_DIR/../common
BOOT_DIR=$TARGET/../images/boot/
IMG_DIR=$TARGET/../images
UBOOT_DIR=$TARGET/../build/host-uboot-tools-*

# copy System.map
cp $TARGET/../build/linux-*/System.map $TARGET/System.map

# boot directory
mkdir -p $BOOT_DIR

cp $IMG_DIR/uImage $BOOT_DIR
cp $IMG_DIR/script.bin $BOOT_DIR

$UBOOT_DIR/tools/mkimage -C none -A arm -T script -d $BOARD_DIR/boot.cmd $BOOT_DIR/boot.scr

# disable software updating
sed -i 's/enable_update=True/enable_update=False/' $TARGET/programs/motioneye/src/handlers.py

$COMMON_DIR/startup-scripts.sh
$COMMON_DIR/cleanups.sh


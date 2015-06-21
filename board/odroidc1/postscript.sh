#!/bin/sh

export TARGET="$1"
export BOARD=$(basename $0)

BOARD_DIR=$(dirname $0)
COMMON_DIR=$BOARD_DIR/../common
BOOT_DIR=$TARGET/../images/boot/
IMG_DIR=$TARGET/../images

# copy System.map
cp $TARGET/../build/linux-*/System.map $TARGET/System.map

# boot directory
mkdir -p $BOOT_DIR

cp $IMG_DIR/uImage $BOOT_DIR
cp $IMG_DIR/meson8b_odroidc.dtb $BOOT_DIR
cp $BOARD_DIR/bl1.bin.hardkernel $IMG_DIR
cp $BOARD_DIR/u-boot.bin $IMG_DIR
cp $BOARD_DIR/boot.ini $BOOT_DIR

# disable software updating
sed -i 's/enable_update=True/enable_update=False/' $TARGET/programs/motioneye/src/handlers.py

$COMMON_DIR/startup-scripts.sh
$COMMON_DIR/cleanups.sh


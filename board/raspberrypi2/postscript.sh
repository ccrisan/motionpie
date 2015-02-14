#!/bin/sh

export TARGET="$1"
export BOARD=$(dirname $0)
export COMMON=$BOARD/../common

# copy System.map
cp $TARGET/../build/linux-*/System.map $TARGET/System.map

# copy kernel
cp $TARGET/../images/zImage $TARGET/../images/boot/kernel.img

# copy fwupdater initramfs
cp $BOARD/fwupdater.gz $TARGET/../images/boot/fwupdater.gz

# custom rpi config
cp $BOARD/config.txt $TARGET/../images/boot/config.txt
cp $BOARD/cmdline.txt $TARGET/../images/boot/cmdline.txt

$COMMON/startup-scripts.sh
$COMMON/cleanups.sh

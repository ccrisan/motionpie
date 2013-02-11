#!/bin/sh

TARGET="${1}"

# copy System.map
cp ${TARGET}/../build/linux-*/System.map ${TARGET}/System.map

# move kernel
mv ${TARGET}/../images/zImage ${TARGET}/../images/boot/kernel.img

exit 0


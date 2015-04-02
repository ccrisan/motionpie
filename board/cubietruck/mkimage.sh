#!/bin/bash -e

BOARD_DIR=$(dirname $0)
BOARD=$(basename $BOARD_DIR)
COMMON_DIR=$BOARD_DIR/../common

export IMG_DIR=$BOARD_DIR/../../output/$BOARD/images/
export UBOOT_BIN=$IMG_DIR/u-boot-sunxi-with-spl.bin

$COMMON_DIR/mkimage.sh


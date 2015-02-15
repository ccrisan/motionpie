#!/bin/sh

if [ -z "$1" ]; then
    echo "Usage: $0 <board|all> [mkimage|mkrelease|make_targets...]"
    exit 1
fi

set -e # exit at first error

board=$1
target=${*:2}
cd $(dirname $0)
basedir=$(pwd)

if [ "$board" == "all" ]; then
    boards=$(ls $basedir/configs/*_defconfig | grep -oE '\w+_defconfig$' | cut -d '_' -f 1)
    for b in $boards; do
        if ! $0 $b $target; then
            exit 1
        fi
    done

    exit 0
fi

outputdir=$basedir/output/$board
boarddir=$basedir/board/$board

if ! [ -f $basedir/configs/${board}_defconfig ]; then
    echo "unknown board: $board"
    exit 1
fi

mkdir -p $outputdir

if ! [ -f $outputdir/.config ]; then
    make O=$outputdir ${board}_defconfig
fi

if [ "$target" == "mkimage" ]; then
    $boarddir/mkimage.sh
elif [ "$target" == "mkrelease" ]; then
    $boarddir/mkimage.sh
    rm -f $outputdir/images/motionPie.img.gz
    which pigz &>/dev/null && pigz $outputdir/images/motionPie.img || gzip $outputdir/images/motionPie.img
    mv $outputdir/images/motionPie.img.gz  $basedir/motionpie-$board-$(date +%Y%m%d).img.gz
elif [ -n "$target" ]; then
    make O=$outputdir $target
else
    make O=$outputdir
    $boarddir/mkimage.sh
fi


#!/bin/sh

if [ -z "$1" ]; then
    echo "Usage: $0 <board> [make_target]"
    exit 1
fi

set -e # exit at first error

board=$1
target=$2
cd $(dirname $0)
basedir=$(pwd)
outputdir=$basedir/output/$board
boarddir=$basedir/board/$board

if ! [ -d $boarddir ]; then
    echo "Unsupported board $board"
    exit 1
fi

mkdir -p $outputdir

if ! [ -f $outputdir/.config ]; then
    make O=$outputdir ${board}_defconfig
fi

make O=$outputdir $target

if [ -z "$target" ]; then
    $boarddir/mkimage.sh
fi

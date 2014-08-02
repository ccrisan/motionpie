#!/bin/bash -e

test "root" != "$USER" && exec sudo $0 "$@"

function usage() {
    echo "Usage: $0 <-d sdcard_dev> <-i image_file> [-n ssid:psk]" 1>&2
    exit 1
}

function msg() {
    echo ":: $1"
}

while getopts "d:i:n:" o; do
    case "$o" in
        d)
            SDCARD_DEV=$OPTARG
            ;;
        i)
            DISK_IMG=$OPTARG
            ;;
        n)
            IFS=":" NETWORK=($OPTARG)
            SSID=${NETWORK[0]}
            PSK=${NETWORK[1]}
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z "$SDCARD_DEV" ] || [ -z "$DISK_IMG" ]; then
    usage
fi

function cleanup {
    set +e

    # unmount sdcard
    umount ${SDCARD_DEV}* >/dev/null 2>&1
}

trap cleanup EXIT

ROOT=$(dirname $0)/.root

if ! [ -f $DISK_IMG ]; then
    echo "could not find image file $DISK_IMG"
    exit 1
fi

umount ${SDCARD_DEV}* 2>/dev/null || true
msg "writing disk image to sdcard"
dd if=$DISK_IMG of=$SDCARD_DEV bs=1M
sync

if [ -n "$SSID" ]; then
    msg "mounting sdcard"
    mkdir -p $ROOT
    ROOT_DEV=${SDCARD_DEV}p2 # e.g. /dev/mmcblk0p2
    if ! [ -e ${SDCARD_DEV}p2 ]; then
        ROOT_DEV=${SDCARD_DEV}2 # e.g. /dev/sdc2
    fi
    mount $ROOT_DEV $ROOT

    msg "creating wireless configuration"
    conf=$ROOT/etc/wpa_supplicant.conf
    echo "update_config=1" > $conf
    echo "ctrl_interface=/var/run/wpa_supplicant" >> $conf
    echo "network={" >> $conf
    echo "    ssid=\"$SSID\"" >> $conf
    if [ -n "$PSK" ]; then
        echo "    psk=\"$PSK\"" >> $conf
    fi
    echo -e "}\n" >> $conf
    sync
    
    msg "unmounting sdcard"
    umount $ROOT
    rmdir $ROOT
fi

msg "you can now remove the sdcard"


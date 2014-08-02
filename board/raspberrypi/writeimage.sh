#!/bin/bash -e

test "root" != "$USER" && exec sudo $0 "$@"

function usage() {
    echo "Usage: $0 <-d sdcard_dev> [-n ssid:psk]" 1>&2
    exit 1
}

function msg() {
    echo ":: $1"
}

while getopts "d:n:" o; do
    case "$o" in
        d)
            SDCARD_DEV=$OPTARG
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

if [ -z "$SDCARD_DEV" ]; then
    usage
fi

function cleanup {
    set +e

    # unmount sdcard
    umount ${SDCARD_DEV}* >/dev/null 2>&1
}

trap cleanup EXIT

cd $(dirname $0)
WD=$(pwd)
DISK_IMG=$(ls -1 motionPie*.img 2>/dev/null)

if ! [ -f $DISK_IMG ]; then
    echo "could not find motionPie.img"
    exit 1
fi

umount ${SDCARD_DEV}* 2>/dev/null || true
msg "writing disk image to sdcard"
dd if=$DISK_IMG of=$SDCARD_DEV bs=1M
sync

if [ -n "$SSID" ]; then
    msg "mounting sdcard"
    mkdir -p $WD/tmp
    root_dev=${SDCARD_DEV}p2 # e.g. /dev/mmcblk0p2
    if ! [ -e ${SDCARD_DEV}p2 ]; then
        root_dev=${SDCARD_DEV}2 # e.g. /dev/sdc2
    fi
    root=$WD/tmp
    mount $root_dev $root

    msg "creating wireless configuration"
    conf=$root/etc/wpa_supplicant.conf
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
    umount $root
    rmdir $root
fi

msg "you can now remove the sdcard"


#!/bin/bash -e

test "root" != "$USER" && exec sudo $0 "$@"

function usage() {
    echo "Usage: $0 <-t update|full> [-i input_dir] [-o output_dir] [-m modem:baud:vid:pid:pin:apn:user:pass] [-n ssid:psk] [-w] [-k] [-c]" 1>&2
    exit 1
}

function msg() {
    echo "**** $1 ****"
}

COMPRESS=false
WRITE_CARD=false
KEEP_IMG=false

while getopts "ci:km:n:o:s:t:v:w" o; do
    case "$o" in
        c)
            COMPRESS=true
            ;;
        i)
            INPUT_DIR=$OPTARG
            ;;
        k)
            KEEP_IMG=true
            ;;
        m)
            IFS=":" NETWORK=($OPTARG)
            MODEM=${NETWORK[0]}
            MODEM_BAUD=${NETWORK[1]}
            MODEM_VID=${NETWORK[2]}
            MODEM_PID=${NETWORK[3]}
            MODEM_PIN=${NETWORK[4]}
            APN=${NETWORK[5]}
            APN_USER=${NETWORK[6]}
            APN_PASS=${NETWORK[7]}
            ;;
        n)
            IFS=":" NETWORK=($OPTARG)
            SSID=${NETWORK[0]}
            PSK=${NETWORK[1]}
            ;;
        o)
            OUTPUT_DIR=$OPTARG
            ;;
        t)
            TYPE=$OPTARG
            test $TYPE == "update" || test $TYPE == "full" || usage
            ;;
        w)
            WRITE_CARD=true
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z "$TYPE" ]; then
    usage
fi

function cleanup {
    # unmount loop mounts
    set +e
    mount | grep /dev/loop | cut -d ' ' -f 3 | xargs -r umount

    # remove loop devices
    losetup -a | cut -d ':' -f 1 | xargs -r losetup -d
}

trap cleanup EXIT

cd $(dirname $0)
SCRIPT_DIR=$(pwd)

if [ -z "$INPUT_DIR" ]; then
    INPUT_DIR=$SCRIPT_DIR
fi

if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR=$SCRIPT_DIR
fi

echo "type = $TYPE"
echo "compress = $COMPRESS"
echo "input dir = $INPUT_DIR"
echo "output dir = $OUTPUT_DIR"
echo "write card = $WRITE_CARD"
echo "keep img = $KEEP_IMG"
echo "network = $SSID:$PSK"
echo "modem = $MODEM:$MODEM_BAUD:$MODEM_VID:$MODEM_PID:$MODEM_PIN:$APN:$APN_USER:$APN_PASS"

SDCARD_DEV="/dev/mmcblk0"

PROG_ROOT="/programs"
PROG_DIR="$PROG_ROOT/motioneye/"

BOOT_SRC=$INPUT_DIR/boot
BOOT=$OUTPUT_DIR/.boot
BOOT_IMG=$OUTPUT_DIR/boot.img
BOOT_SIZE="16" # MB

ROOT_SRC=$INPUT_DIR/rootfs.tar
ROOT=$OUTPUT_DIR/.root
ROOT_IMG=$OUTPUT_DIR/root.img
ROOT_SIZE="160" # MB

DISK_SIZE="200" # MB

mkdir -p $OUTPUT_DIR

# boot filesystem
echo "creating boot loop device"
dd if=/dev/zero of=$BOOT_IMG bs=1M count=$BOOT_SIZE
loop_dev=$(losetup -f)
losetup -f $BOOT_IMG

msg "creating boot filesystem"
mkfs.vfat -F16 $loop_dev

msg "mounting boot loop device"
mkdir -p $BOOT
mount -o loop $loop_dev $BOOT

msg "copying boot filesystem contents"
cp $BOOT_SRC/bootcode.bin $BOOT
cp $BOOT_SRC/config.txt $BOOT
cp $BOOT_SRC/cmdline.txt $BOOT
cp $BOOT_SRC/start_x.elf $BOOT
cp $BOOT_SRC/fixup_x.dat $BOOT
cp $BOOT_SRC/kernel.img $BOOT
sync

msg "unmounting boot filesystem"
umount $BOOT

msg "destroying boot loop device"
losetup -d $loop_dev
sync

# root filesystem
msg "creating root loop device"
dd if=/dev/zero of=$ROOT_IMG bs=1M count=$ROOT_SIZE
loop_dev=$(losetup -f)
losetup -f $ROOT_IMG

msg "creating root filesystem"
mkfs.ext4 $loop_dev
#tune2fs -O^has_journal $loop_dev

msg "mounting root loop device"
mkdir -p $ROOT
mount -o loop $loop_dev $ROOT

msg "copying root filesystem contents"
tar -xpsf $ROOT_SRC -C $ROOT

if [ -n "$SSID" ]; then
    msg "creating default wireless configuration"
    conf=$ROOT/etc/wpa_supplicant.conf
    echo "update_config=1" > $conf
    echo "ctrl_interface=/var/run/wpa_supplicant" >> $conf
    echo "network={" >> $conf
    echo "    ssid=\"$SSID\"" >> $conf
    if [ -n "$PSK" ]; then
        echo "    psk=\"$PSK\"" >> $conf
    fi
    echo -e "}\n" >> $conf
fi

if [ -n "$MODEM" ]; then
    msg "creating default modem configuration"
    conf=$ROOT/etc/ppp/default/
    mkdir -p $conf

    if [ -n "$APN" ]; then
        echo "AT+CGDCONT=1,\"IP\",\"$APN\"" > $conf/apn
    else
        echo "AT" > $conf/apn
    fi

    echo -n > $conf/auth
    if [ -n "$APN_USER" ]; then
        echo "user \"$APN_USER\"" >> $conf/auth
    fi
    if [ -n "$APN_PASS" ]; then
        echo "password \"$APN_PASS\"" >> $conf/auth
    fi
    
    echo 'AT' > $conf/extra
    
    echo $MODEM > $conf/modem
    echo $MODEM_BAUD >> $conf/modem
    
    if [ -n "$MODEM_PIN" ]; then
        echo "AT+CPIN=\"$MODEM_PIN\"" > $conf/pin
    else
        echo "AT" > $conf/pin
    fi
    
    if [ -n "$MODEM_VID" ] && [ -n "$MODEM_PID" ]; then
        echo $MODEM_VID:$MODEM_PID > $conf/usb_modeswitch
    fi
fi

sync

msg "unmounting root filesystem"
umount $ROOT

msg "destroying root loop device"
losetup -d $loop_dev
sync

case "$TYPE" in
    update)
        cd $OUTPUT_DIR
        tar_opts="cvf"
        tar_filename="motioneye-update.tar"
        if [ "$COMPRESS" == "true" ]; then
            tar_opts="z$tar_opts"
            tar_filename=$tar_filename.gz
        fi

        tar $tar_opts $tar_filename boot.img root.img

        if [ "$KEEP_IMG" == "false" ]; then
            rm boot.img root.img
        fi
        ;;

    full)
        cd $OUTPUT_DIR
        DISK_IMG=$OUTPUT_DIR/disk.img
        BOOT_IMG=$OUTPUT_DIR/boot.img
        ROOT_IMG=$OUTPUT_DIR/root.img

        if ! [ -r $BOOT_IMG ]; then
            echo "boot image missing"
            exit -1
        fi

        if ! [ -r $ROOT_IMG ]; then
            echo "root image missing"
            exit -1
        fi

        # disk image
        msg "creating disk loop device"
        dd if=/dev/zero of=$DISK_IMG bs=1M count=$DISK_SIZE
        loop_dev=$(losetup -f)
        losetup -f $DISK_IMG

        msg "partitioning disk"
        set +e
        fdisk $loop_dev <<END
o
n
p
1

+${BOOT_SIZE}M
n
p
2

+${ROOT_SIZE}M

t
1
e
a
1
w
END
        set -e
        sync

        echo "reading partition offsets"
        boot_offs=$(fdisk -l $loop_dev | grep -E 'loop[[:digit:]]p1' | tr -d '*' | tr -s ' ' | cut -d ' ' -f 2)
        root_offs=$(fdisk -l $loop_dev | grep -E 'loop[[:digit:]]p2' | tr -d '*' | tr -s ' ' | cut -d ' ' -f 2)

        echo "destroying disk loop device"
        losetup -d $loop_dev

        msg "creating boot loop device"
        loop_dev=$(losetup -f)
        losetup -f -o $(($boot_offs * 512)) $DISK_IMG

        msg "copying boot image"
        dd if=$BOOT_IMG of=$loop_dev
        sync

        echo "destroying boot loop device"
        losetup -d $loop_dev

        msg "creating root loop device"
        loop_dev=$(losetup -f)
        losetup -f -o $(($root_offs * 512)) $DISK_IMG
        sync

        msg "copying root image"
        dd if=$ROOT_IMG of=$loop_dev
        sync

        echo "destroying root loop device"
        losetup -d $loop_dev
        sync

        if [ "$KEEP_IMG" == "false" ]; then
            rm $ROOT_IMG $BOOT_IMG
        fi

        mv $DISK_IMG $(dirname $DISK_IMG)/motioneye-full.img
        DISK_IMG=$(dirname $DISK_IMG)/motioneye-full.img

        if [ "$WRITE_CARD" == "true" ]; then
            umount ${SDCARD_DEV}* || true
            echo "writing disk image to sdcard"
            dd if=$DISK_IMG of=$SDCARD_DEV
            sync
        fi

        if [ "$COMPRESS" == "true" ]; then
            gzip $DISK_IMG
            mv $DISK_IMG.gz $DISK_IMG
        fi

        ;;
esac

msg "done"


#!/bin/bash -e


function usage() {
    echo "Usage: $0 <-d sdcard_dev> <-i image_file> [-l] [-n ssid:psk] [-o none|modest|medium|high|turbo] [-p port] [-s ip/cidr:gw:dns] [-w]" 1>&2
    echo "    -d sdcard_dev - indicates the path to the sdcard block device (e.g. -d /dev/mmcblk0)"
    echo "    -i image_file - indicates the path to the image file (e.g. -i /home/user/Download/motionPie.img)"
    echo "    -l - disables the LED of the CSI camera module"
    echo "    -n ssid:psk - sets the wireless network name and key (e.g. -n mynet:mykey1234)"
    echo "    -o none|modest|medium|high|turbo - overclocks the PI according to a preset (e.g. -o high)"
    echo "    -p port - listen on the given port rather than on 80 (e.g. -p 8080)"
    echo "    -s ip/cidr:gw:dns - sets a static IP configuration instead of DHCP (e.g. -s 192.168.3.107/24:192.168.3.1:8.8.8.8)"
    echo "    -w - disables rebooting when the wireless connection is lost"
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

test "root" != "$USER" && exec sudo $0 "$@"

function msg() {
    echo ":: $1"
}

while getopts "d:i:ln:o:p:s:w" o; do
    case "$o" in
        d)
            SDCARD_DEV=$OPTARG
            ;;
        i)
            DISK_IMG=$OPTARG
            ;;
        l)
            DISABLE_LED=true
            ;;
        n)
            IFS=":" NETWORK=($OPTARG)
            SSID=${NETWORK[0]}
            PSK=${NETWORK[1]}
            ;;
        o)
            OC_PRESET=$OPTARG
            ;;
        p)
            PORT=$OPTARG
            ;;
        s)
            IFS=":" S_IP=($OPTARG)
            IP=${S_IP[0]}
            GW=${S_IP[1]}
            DNS=${S_IP[2]}
            ;;
        w)
            DISABLE_WR=true
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

BOOT=$(dirname $0)/.boot
ROOT=$(dirname $0)/.root

if ! [ -f $DISK_IMG ]; then
    echo "could not find image file $DISK_IMG"
    exit 1
fi

umount ${SDCARD_DEV}* 2>/dev/null || true
msg "writing disk image to sdcard"
dd if=$DISK_IMG of=$SDCARD_DEV bs=1M
sync

if which partprobe > /dev/null 2>&1; then
    msg "re-reading sdcard partition table"
    partprobe ${SDCARD_DEV}
fi

msg "mounting sdcard"
mkdir -p $BOOT
mkdir -p $ROOT
BOOT_DEV=${SDCARD_DEV}p1 # e.g. /dev/mmcblk0p1
ROOT_DEV=${SDCARD_DEV}p2 # e.g. /dev/mmcblk0p2
if ! [ -e ${SDCARD_DEV}p1 ]; then
    BOOT_DEV=${SDCARD_DEV}1 # e.g. /dev/sdc1
    ROOT_DEV=${SDCARD_DEV}2 # e.g. /dev/sdc2
fi
mount $BOOT_DEV $BOOT
mount $ROOT_DEV $ROOT

if [ -n "$DISABLE_LED" ]; then
    msg "disabling camera LED"
    echo "disable_camera_led=1" >> $BOOT/config.txt
fi

if [ -n "$OC_PRESET" ]; then
    msg "setting overclocking to $OC_PRESET"
    case $OC_PRESET in
        none)
            ARM_FREQ="700"
            CORE_FREQ="250"
            SDRAM_FREQ="400"
            OVER_VOLTAGE="0"
            ;;

        modest)
            ARM_FREQ="800"
            CORE_FREQ="250"
            SDRAM_FREQ="400"
            OVER_VOLTAGE="0"
            ;;

        medium)
            ARM_FREQ="900"
            CORE_FREQ="250"
            SDRAM_FREQ="450"
            OVER_VOLTAGE="2"
            ;;

        high)
            ARM_FREQ="950"
            CORE_FREQ="250"
            SDRAM_FREQ="450"
            OVER_VOLTAGE="6"
            ;;

        turbo)
            ARM_FREQ="1000"
            CORE_FREQ="500"
            SDRAM_FREQ="600"
            OVER_VOLTAGE="6"
            ;;
    esac

    if [ -n "$ARM_FREQ" ]; then
        sed -Ei "s/arm_freq=[[:digit:]]+/arm_freq=$ARM_FREQ/" $BOOT/config.txt
        sed -Ei "s/core_freq=[[:digit:]]+/core_freq=$CORE_FREQ/" $BOOT/config.txt
        sed -Ei "s/sdram_freq=[[:digit:]]+/sdram_freq=$SDRAM_FREQ/" $BOOT/config.txt
        sed -Ei "s/over_voltage=[[:digit:]]+/over_voltage=$OVER_VOLTAGE/" $BOOT/config.txt
    fi
fi

if [ -n "$SSID" ]; then
    msg "creating wireless configuration"
    conf=$ROOT/etc/wpa_supplicant.conf
    echo "update_config=1" > $conf
    echo "ctrl_interface=/var/run/wpa_supplicant" >> $conf
    echo "network={" >> $conf
    echo "    scan_ssid=1" >> $conf
    echo "    ssid=\"$SSID\"" >> $conf
    if [ -n "$PSK" ]; then
        echo "    psk=\"$PSK\"" >> $conf
    fi
    echo -e "}\n" >> $conf
fi

if [ -n "$IP" ] && [ -n "$GW" ] && [ -n "$DNS" ]; then
    msg "setting static IP configuration"
    conf=$ROOT/etc/static_ip.conf
    echo "static_ip=\"$IP\"" > $conf
    echo "static_gw=\"$GW\"" >> $conf
    echo "static_dns=\"$DNS\"" >> $conf
fi

if [ -n "$PORT" ]; then
    msg "setting server port to $PORT"
    sed -i "s%PORT = 80%PORT = $PORT%" $ROOT/programs/motioneye/settings.py
fi

if [ -n "$DISABLE_WR" ]; then
    msg "disabling no-wireless reboot"
    sed -i 's%rebooting%ignoring%' $ROOT/etc/init.d/S35wifi
    sed -i 's%reboot%%' $ROOT/etc/init.d/S35wifi
    sed -i 's%rebooting%ignoring%' $ROOT/etc/init.d/S36ppp
    sed -i 's%reboot%%' $ROOT/etc/init.d/S36ppp
fi

msg "unmounting sdcard"
sync
umount $BOOT
umount $ROOT
rmdir $BOOT
rmdir $ROOT

msg "you can now remove the sdcard"


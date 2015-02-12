#!/bin/bash -e


function usage() {
    echo "Usage: $0 [options...]" 1>&2
    echo ""
    echo "Available options:"
    echo "    <-i image_file> - indicates the path to the image file (e.g. -i /home/user/Download/motionPie.img)"
    echo "    <-d sdcard_dev> - indicates the path to the sdcard block device (e.g. -d /dev/mmcblk0)"
    echo "    [-a off|public|auth|writable] - configures the internal samba server (e.g. -a auth)"
    echo "        default - shares are read-only, no authentication required"
    echo "        off - samba server disabled"
    echo "        public - shares are read-only, no authentication required"
    echo "        auth - shares are read-only, authentication required"
    echo "        writable - shares are writable, authentication required"
    echo "    [-f off|public|auth|writable] - configures the internal ftp server (e.g. -f auth)"
    echo "        default - read-only mode, anonymous logins"
    echo "        off - ftp server disabled"
    echo "        public - read-only mode, anonymous logins"
    echo "        auth - read-only mode, authentication required"
    echo "        writable - writable mode, authentication required"
    echo "    [-h off|on] - configures the internal ssh server (e.g. -h on)"
    echo "        default - ssh server enabled"
    echo "        off - ssh server disabled"
    echo "        on - ssh server enabled"
    echo "    [-l] - enables the LED on the CSI camera module"
    echo "    [-n ssid:psk] - sets the wireless network name and key (e.g. -n mynet:mykey1234)"
    echo "    [-o none|modest|medium|high|turbo] - overclocks the PI according to a preset (e.g. -o high)"
    echo "        default - arm=900Mhz, core=500Mhz, sdram=500MHz, ov=6"
    echo "        none - arm=700Mhz, core=250Mhz, sdram=400MHz, ov=0"
    echo "        modest - arm=800Mhz, core=250Mhz, sdram=400MHz, ov=0"
    echo "        medium - arm=900Mhz, core=250Mhz, sdram=450MHz, ov=2"
    echo "        high - arm=950Mhz, core=250Mhz, sdram=450MHz, ov=6"
    echo "        turbo - arm=1000Mhz, core=500Mhz, sdram=600MHz, ov=6"
    echo "    [-p port] - listen on the given port rather than on 80 (e.g. -p 8080)"
    echo "    [-s ip/cidr:gw:dns] - sets a static IP configuration instead of DHCP (e.g. -s 192.168.3.107/24:192.168.3.1:8.8.8.8)"
    echo "    [-w] - disables rebooting when the network connection is lost"
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

test "root" != "$USER" && exec sudo $0 "$@"

function msg() {
    echo ":: $1"
}

while getopts "a:d:f:h:i:ln:o:p:s:w" o; do
    case "$o" in
        a)
            SMB_MODE=$OPTARG
            ;;
        d)
            SDCARD_DEV=$OPTARG
            ;;
        f)
            FTP_MODE=$OPTARG
            ;;
        h)
            SSH_MODE=$OPTARG
            ;;
        i)
            DISK_IMG=$OPTARG
            ;;
        l)
            ENABLE_LED=true
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
            DISABLE_NR=true
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
dd if=$DISK_IMG of=$SDCARD_DEV bs=1048576
sync

if which partprobe > /dev/null 2>&1; then
    msg "re-reading sdcard partition table"
    partprobe ${SDCARD_DEV}
fi

msg "mounting sdcard"
mkdir -p $BOOT
mkdir -p $ROOT

if [ `uname` == "Darwin" ]; then
    if ! [ -x /sbin/mount_fuse-ext2 ]; then
        echo "Missing mount_fuse-ext2 for EXT4 mounting! Further configuration stopped."
        echo ""
        echo "See http://osxdaily.com/2014/03/20/mount-ext-linux-file-system-mac/"
        echo "how to install ext4 mount support, please include 'Enabling EXT Write Support'."
        echo ""
        exit 1
    fi
    BOOT_DEV=${SDCARD_DEV}s1 # e.g. /dev/disk4s1
    ROOT_DEV=${SDCARD_DEV}s2 # e.g. /dev/disk4s2
    mount_msdos $BOOT_DEV $BOOT
    mount_fuse-ext2 $ROOT_DEV $ROOT    
else # assuming Linux
    BOOT_DEV=${SDCARD_DEV}p1 # e.g. /dev/mmcblk0p1
    ROOT_DEV=${SDCARD_DEV}p2 # e.g. /dev/mmcblk0p2
    if ! [ -e ${SDCARD_DEV}p1 ]; then
        BOOT_DEV=${SDCARD_DEV}1 # e.g. /dev/sdc1
        ROOT_DEV=${SDCARD_DEV}2 # e.g. /dev/sdc2
    fi
    mount $BOOT_DEV $BOOT
    mount $ROOT_DEV $ROOT
fi

# samba
if [ -n "$SMB_MODE" ] && [ "$SMB_MODE" != "public" ]; then
    msg "setting smb mode to $SMB_MODE"
    case $SMB_MODE in
        off)
            rm $ROOT/etc/init.d/S91smb
            rm -r $ROOT/etc/samba/
            ;;
        auth)
            sed -Ei.bak "s/public = yes/public = no/" $ROOT/etc/samba/smb.conf
            ;;
        writable)
            sed -Ei.bak "s/public = yes/public = no/" $ROOT/etc/samba/smb.conf
            sed -Ei.bak "s/writable = no/writable = yes/" $ROOT/etc/samba/smb.conf
            ;;
        *)
            echo "invalid smb mode $SMB_MODE"
            ;;
    esac
fi

# ftp
if [ -n "$FTP_MODE" ] && [ "$FTP_MODE" != "public" ]; then
    msg "setting ftp mode to $FTP_MODE"
    case $FTP_MODE in
        off)
            rm $ROOT/etc/init.d/S70proftpd
            rm -r $ROOT/etc/proftpd.conf
            ;;
        auth)
            sed -Ei.bak "s/RootLogin off/RootLogin on/" $ROOT/etc/proftpd.conf
            sed -Ei.bak "s/Anonymous ~ftp/Anonymous ~ftpdisabled/" $ROOT/etc/proftpd.conf
            ;;
        writable)
            sed -Ei.bak "s/RootLogin off/RootLogin on/" $ROOT/etc/proftpd.conf
            sed -Ei.bak "s/Anonymous ~ftp/Anonymous ~ftpdisabled/" $ROOT/etc/proftpd.conf
            sed -Ei.bak "s/DenyAll #rwmark/AllowAll/" $ROOT/etc/proftpd.conf
            ;;
        *)
            echo "invalid ftp mode $FTP_MODE"
            ;;
    esac
fi

# ssh
if [ -n "$SSH_MODE" ] && [ "$SSH_MODE" != "on" ]; then
    msg "setting ssh mode to $SSH_MODE"
    case $SSH_MODE in
        off)
            rm $ROOT/etc/init.d/S50sshd
            rm $ROOT/etc/sshd_config
            ;;
        *)
            echo "invalid ssh mode $SSH_MODE"
            ;;
    esac
fi

# camera led
if [ -n "$ENABLE_LED" ]; then
    msg "enabling camera LED"
    sed -i.bak "s/disable_camera_led=1/disable_camera_led=0/" $BOOT/config.txt
fi

# overclocking
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
        *)
            echo "invalid overclocking preset $OC_PRESET"
            ;;
    esac

    if [ -n "$ARM_FREQ" ]; then
        sed -Ei.bak "s/arm_freq=[[:digit:]]+/arm_freq=$ARM_FREQ/" $BOOT/config.txt
        sed -Ei.bak "s/core_freq=[[:digit:]]+/core_freq=$CORE_FREQ/" $BOOT/config.txt
        sed -Ei.bak "s/sdram_freq=[[:digit:]]+/sdram_freq=$SDRAM_FREQ/" $BOOT/config.txt
        sed -Ei.bak "s/over_voltage=[[:digit:]]+/over_voltage=$OVER_VOLTAGE/" $BOOT/config.txt
    fi
fi

# wifi
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

# static ip
if [ -n "$IP" ] && [ -n "$GW" ] && [ -n "$DNS" ]; then
    msg "setting static IP configuration"
    conf=$ROOT/etc/static_ip.conf
    echo "static_ip=\"$IP\"" > $conf
    echo "static_gw=\"$GW\"" >> $conf
    echo "static_dns=\"$DNS\"" >> $conf
fi

# port
if [ -n "$PORT" ]; then
    msg "setting server port to $PORT"
    sed -i.bak "s%PORT = 80%PORT = $PORT%" $ROOT/programs/motioneye/settings.py
fi

# rebooting upon network issues
if [ -n "$DISABLE_NR" ]; then
    msg "disabling reboot on network errors"
    sed -i.bak 's%link_watch=yes%link_watch=no%' $ROOT/etc/watch.conf
    sed -i.bak 's%ip_watch=yes%ip_watch=no%' $ROOT/etc/watch.conf
fi

msg "removing .bak files"
find $BOOT/ -type f -name "*.bak" -exec rm -f {} \;
find $ROOT/etc -type f -name "*.bak" -exec rm -f {} \;

msg "unmounting sdcard"
sync
umount $BOOT
umount $ROOT
rmdir $BOOT
rmdir $ROOT

msg "you can now remove the sdcard"


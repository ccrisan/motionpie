setenv bootargs console=tty1 root=/dev/mmcblk0p2 rootwait panic=10 earlyprintk ${extra}
fatload mmc 0 0x49000000 meson8b_odroidc.dtb
fatload mmc 0 0x46000000 uImage
bootm 0x46000000 - 0x49000000


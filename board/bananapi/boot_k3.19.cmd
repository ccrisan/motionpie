setenv bootargs console=ttyS0,115200 console=ttyS0,115200 root=/dev/mmcblk0p2 rootwait panic=10 ${extra}
fatload mmc 0 0x46000000 uImage
fatload mmc 0 0x49000000 sun7i-a20-bananapi.dtb
bootm 0x46000000 - 0x49000000


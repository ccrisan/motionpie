#! /bin/sh
#
# S00raspberrypi.sh - Raspberry Pi startup script
#

case "$1" in
	start|"")
		echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

		modprobe evdev
		modprobe snd-bcm2835
		# modprobe bcm2708_wdog
		# modprobe i2c-bcm2708
		# modprobe spi-bcm2708
		;;
	stop)
		# rmmod spi-bcm2708
		# rmmod i2c-bcm2708
		# rmmod bcm2708_wdog
		rmmod snd-bcm2835
		rmmod evdev
		;;
	*)
		echo "Usage: S00raspberrypi.sh {start|stop}" >&2
		exit 1
		;;
esac

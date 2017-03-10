#!/sbin/busybox sh

set +x
_PATH="$PATH"
export PATH=/sbin

busybox cd /
busybox date >> boot.log
exec >> boot.log 2>&1
busybox rm /init

source /sbin/bootrec-device

busybox mkdir -m 555 -p /proc
busybox mkdir -m 755 -p /sys

busybox mount -t proc proc /proc
busybox mount -t sysfs sysfs /sys

busybox mknod -m 666 /dev/null c 1 3

busybox echo 400 > /sys/class/leds/lcd-backlight/brightness
busybox echo 120 > /sys/class/timed_output/vibrator/enable

if busybox grep -q ${BOOTREC_CODE_VOLDN} ${BOOTREC_GPIO} || busybox grep -q warmboot=0x77665502 /proc/cmdline ; then

	busybox echo 13  > ${BOOTREC_LED_RED}
	busybox echo 213 > ${BOOTREC_LED_GREEN}
	busybox echo 253 > ${BOOTREC_LED_BLUE}

	busybox echo 'TWRP Recovery Boot' >> boot.log

#	busybox lzma -d /sbin/recovery-twrp.cpio.lzma
	load_image=/sbin/recovery-twrp.cpio

else

	busybox echo 0   > ${BOOTREC_LED_RED}
	busybox echo 255 > ${BOOTREC_LED_GREEN}
	busybox echo 0   > ${BOOTREC_LED_BLUE}

	busybox echo 'Normal Android Boot' >> boot.log

#	busybox lzma -d /sbin/ramdisk.cpio.lzma
	load_image=/sbin/ramdisk.cpio

fi

busybox echo 0 > ${BOOTREC_LED_RED}
busybox echo 0 > ${BOOTREC_LED_GREEN}
busybox echo 0 > ${BOOTREC_LED_BLUE}

busybox cpio -i < ${load_image}

busybox umount /proc
busybox umount /sys

busybox rm -fr /dev/*
busybox rm /sbin/*.lzma
busybox rm /sbin/*.cpio

export PATH="${_PATH}"
exec /init

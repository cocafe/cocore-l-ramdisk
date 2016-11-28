#!/sbin/busybox sh

set +x
_PATH="$PATH"
export PATH=/sbin

busybox cd /
busybox date >> boot.log
exec >> boot.log 2>&1
busybox rm /init

source /sbin/bootrec-device

load_image=/sbin/ramdisk.cpio

busybox mkdir -m 555 -p /proc
busybox mkdir -m 755 -p /sys

busybox mount -t proc proc /proc
busybox mount -t sysfs sysfs /sys

busybox mknod -m 666 /dev/null c 1 3

# EMERGENCY DEBUG
# busybox mknod -m 666 /mmcblksos b 179 24

# busybox mkdir /sos
# busybox mkdir /sos/proc
# busybox mkdir /sos/cache

# busybox mount -t proc proc /sos/proc
# busybox mount -t ext4 /mmcblksos /sos/cache

# busybox tail -f /boot.log > /sos/cache/boot.log &
# busybox cat /sos/proc/kmsg > /sos/cache/kmsg.log &
# EMERGENCY DEBUG END

busybox echo 120 > /sys/class/timed_output/vibrator/enable

if busybox grep -q '115' ${BOOTREC_GPIO} ; then

	busybox echo 200 > ${BOOTREC_LED_RED}
	busybox echo 96  > ${BOOTREC_LED_GREEN}
	busybox echo 0 > ${BOOTREC_LED_BLUE}

	# busybox echo 'CWM Recovery Boot' >> boot.log

	# busybox lzma -d /sbin/recovery-cwm.cpio.lzma
	# load_image=/sbin/recovery-cwm.cpio

elif busybox grep -q '114' ${BOOTREC_GPIO} || busybox grep -q warmboot=0x77665502 /proc/cmdline ; then

	busybox echo 13  > ${BOOTREC_LED_RED}
	busybox echo 213 > ${BOOTREC_LED_GREEN}
	busybox echo 253 > ${BOOTREC_LED_BLUE}

	busybox echo 'TWRP Recovery Boot' >> boot.log

	busybox lzma -d /sbin/recovery-twrp.cpio.lzma
	load_image=/sbin/recovery-twrp.cpio

else

	busybox echo 0   > ${BOOTREC_LED_RED}
	busybox echo 255 > ${BOOTREC_LED_GREEN}
	busybox echo 0   > ${BOOTREC_LED_BLUE}

	busybox echo 'Normal Android Boot' >> boot.log

	busybox lzma -d /sbin/ramdisk.cpio.lzma

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

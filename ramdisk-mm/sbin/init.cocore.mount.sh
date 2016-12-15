#!/sbin/busybox sh

BB=/sbin/busybox
LOG=/boot.log

MNT_CACHE=/cache
MNT_SYSTEM=/system
MNT_USERDATA=/data

BLK_CACHE=/dev/block/mmcblk0p24
BLK_SYSTEM=/dev/block/mmcblk0p23
BLK_USERDATA=/dev/block/mmcblk0p25

VOL_UP=115
VOL_DN=114
GPIO_KEY=/sys/devices/gpio_keys.82/keys_pressed
VIBRATOR=/sys/class/timed_output/vibrator/enable

LED_RED=/sys/class/leds/led\:rgb_red/brightness
LED_GREEN=/sys/class/leds/led\:rgb_green/brightness
LED_BLUE=/sys/class/leds/led\:rgb_blue/brightness

FSCK_EXT4=/sbin/e2fsck_static
FSCK_F2FS=/sbin/fsck.f2fs

FSCK_FORCE=false

led_blkid()
{
  ${BB} echo 200 > ${LED_RED}
  ${BB} echo 96  > ${LED_GREEN}
  ${BB} echo 0   > ${LED_BLUE}
}

led_premount()
{
  ${BB} echo 0   > ${LED_RED}
  ${BB} echo 150 > ${LED_GREEN}
  ${BB} echo 150 > ${LED_BLUE}
}

led_ext4()
{
  ${BB} echo 13  > ${LED_RED}
  ${BB} echo 213 > ${LED_GREEN}
  ${BB} echo 253 > ${LED_BLUE}
}

led_f2fs()
{
  ${BB} echo 255 > ${LED_RED}
  ${BB} echo 153 > ${LED_GREEN}
  ${BB} echo 0   > ${LED_BLUE}
}

led_finish()
{
  ${BB} echo 0 > ${LED_RED}
  ${BB} echo 0 > ${LED_GREEN}
  ${BB} echo 0 > ${LED_BLUE}
}

# redirect output
exec >> ${LOG} 2>&1

led_blkid

# avoid calling blkid multiple times
${BB} blkid ${BLK_SYSTEM}   >> ${LOG}
${BB} blkid ${BLK_CACHE}    >> ${LOG}
${BB} blkid ${BLK_USERDATA} >> ${LOG}

if ${BB} grep -q ${VOL_UP} ${GPIO_KEY}; then
  FSCK_FORCE=true
  ${BB} echo 200 > ${VIBRATOR}
fi

led_premount

if ${BB} cat ${LOG} | ${BB} grep ${BLK_SYSTEM} | ${BB} grep -q "ext4"; then

  ${BB} echo "init.cocore.mount.sh: [system] [ext4]"
  led_ext4

  if ${BB} [ ${FSCK_FORCE} = true ]; then
    ${BB} echo "init.cocore.mount.sh: force fsck on [system]"
    ${FSCK_EXT4} -pvaf ${BLK_SYSTEM}
  else
    ${FSCK_EXT4} -y ${BLK_SYSTEM}
  fi

  ${BB} mount -t ext4 -o ro,seclabel,noatime,discard ${BLK_SYSTEM} ${MNT_SYSTEM}

elif ${BB} cat ${LOG} | ${BB} grep ${BLK_SYSTEM} | ${BB} grep -q "f2fs"; then

  ${BB} echo "init.cocore.mount.sh: [system] [f2fs]"
  led_f2fs

  if ${BB} [ ${FSCK_FORCE} = true ]; then
    ${BB} echo "init.cocore.mount.sh: force fsck on [system]"
    ${FSCK_F2FS} -f ${BLK_SYSTEM}
  else
    ${FSCK_F2FS} -a ${BLK_SYSTEM}
  fi

  ${BB} mount -t f2fs -o background_gc=on,discard,inline_xattr,inline_data,inline_dentry,flush_merge,extent_cache,data_flush,active_logs=2 ${BLK_SYSTEM} ${MNT_SYSTEM}

fi

led_premount

if ${BB} cat ${LOG} | ${BB} grep ${BLK_USERDATA} | ${BB} grep -q "ext4"; then

  ${BB} echo "init.cocore.mount.sh: [userdata] [ext4]"
  led_ext4

  if ${BB} [ ${FSCK_FORCE} = true ]; then
    ${BB} echo "init.cocore.mount.sh: force fsck on [userdata]"
    ${FSCK_EXT4} -pvaf ${BLK_USERDATA}
  else
    ${FSCK_EXT4} -y ${BLK_USERDATA}
  fi

  ${BB} mount -t ext4 -o rw,seclabel,nosuid,nodev,relatime,discard,noauto_da_alloc ${BLK_USERDATA} ${MNT_USERDATA}

elif ${BB} cat ${LOG} | ${BB} grep ${BLK_USERDATA} | ${BB} grep -q "f2fs"; then

  ${BB} echo "init.cocore.mount.sh: [userdata] [f2fs]"
  led_f2fs

  if ${BB} [ ${FSCK_FORCE} = true ]; then
    ${BB} echo "init.cocore.mount.sh: force fsck on [userdata]"
    ${FSCK_F2FS} -f ${BLK_USERDATA}
  else
    ${FSCK_F2FS} -a ${BLK_USERDATA}
  fi

  ${BB} mount -t f2fs -o background_gc=on,discard,inline_xattr,inline_data,inline_dentry,flush_merge,extent_cache,data_flush,active_logs=4 ${BLK_USERDATA} ${MNT_USERDATA}
  
fi

led_premount

if ${BB} cat ${LOG} | ${BB} grep ${BLK_CACHE} | ${BB} grep -q "ext4"; then

  ${BB} echo "init.cocore.mount.sh: [cache] [ext4]"
  led_ext4

  if ${BB} [ ${FSCK_FORCE} = true ]; then
    ${BB} echo "init.cocore.mount.sh: force fsck on [cache]"
    ${FSCK_EXT4} -pvaf ${BLK_CACHE}
  else
    ${FSCK_EXT4} -y ${BLK_CACHE}
  fi

  ${BB} mount -t ext4 -o rw,seclabel,nosuid,nodev,relatime,discard ${BLK_CACHE} ${MNT_CACHE}

elif ${BB} cat ${LOG} | ${BB} grep ${BLK_CACHE} | ${BB} grep -q "f2fs"; then

  ${BB} echo "init.cocore.mount.sh: [cache] [f2fs]"
  led_f2fs

  if ${BB} [ ${FSCK_FORCE} = true ]; then
    ${BB} echo "init.cocore.mount.sh: force fsck on [cache]"
    ${FSCK_F2FS} -f ${BLK_CACHE}
  else
    ${FSCK_F2FS} -a ${BLK_CACHE}
  fi

  ${BB} mount -t f2fs -o background_gc=on,discard,inline_xattr,inline_data,inline_dentry,flush_merge,extent_cache,data_flush,active_logs=2 ${BLK_CACHE} ${MNT_CACHE}
  
fi

led_finish

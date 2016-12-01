#!/system/bin/sh

LOG=/boot.log

if mount | grep rootfs | grep -q ro; then
  mount -o rw,remount /
fi

# save logs
echo "init.cocore.early_init: `date`" >> ${LOG}
exec >> ${LOG} 2>&1

# create init.early folder if not exists
if [ ! -e /system/etc/init.early ]; then
  echo "init.cocore.early_init: create init.early directory"
  mount -o rw,remount /system
  mkdir /system/etc/init.early
  chown root.root /system/etc/init.early
  chmod 755 /system/etc/init.early
fi

# start init.d
for FILE in /system/etc/init.early/*; do
  sh $FILE >/dev/null
done;
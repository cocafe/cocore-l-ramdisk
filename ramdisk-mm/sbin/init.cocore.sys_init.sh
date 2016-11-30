#!/system/bin/sh

LOG=/boot.log

# save logs
echo "init.cocore.sys_init: `date`" >> ${LOG}
exec >> ${LOG} 2>&1

# create init.d folder if not exists
if [ ! -e /system/etc/init.d ]; then
  echo "init.cocore.sys_init: create init.d directory"
  mount -o rw,remount /system
  mkdir /system/etc/init.d
  chown root.root /system/etc/init.d
  chmod 755 /system/etc/init.d
fi

# start init.d
for FILE in /system/etc/init.d/*; do
  sh $FILE >/dev/null
done;
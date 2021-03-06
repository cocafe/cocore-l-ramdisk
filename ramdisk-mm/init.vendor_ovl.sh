#!/system/bin/sh

# Overlay path: /vendor
OVERLAY_PATH=$1
TARGET=/system/vendor
BB=${OVERLAY_PATH}/bin/busybox

# unpack() {
# 	for file in $1; do
# 		[ -e ${file} ] && ${BB} unxz ${file} && ${BB} chmod $2 ${file%.*}
# 	done
# }

cp /sbin/busybox /vendor/bin/busybox
chmod 0755 /vendor/bin/busybox

for dir in ${OVERLAY_PATH}/*; do
  [ -d ${dir} ] && for file in ${TARGET}/${dir##*/}/*; do
	[ -e ${file} ] && ${BB} ln -s ${file} ${dir}/${file##*/}
  done
done

for file in ${TARGET}/*; do
  ovl_file=${OVERLAY_PATH}/${file##*/}
  [ ! -e ${ovl_file} ] && ${BB} ln -s ${file} ${ovl_file}
done

# SuperSu requires a copy of app_process with context system_file
# other tools with app_process do not work as they would transition into zygote
if [ -e  ${OVERLAY_PATH}/bin/su -a -e /system/bin/app_process ]; then
	${BB} cp /system/bin/app_process ${OVERLAY_PATH}/bin/app_process
	${BB} chmod 0755 ${OVERLAY_PATH}/bin/app_process
fi

# unpack "${OVERLAY_PATH}/bin/*.xz"   0755
# unpack "${OVERLAY_PATH}/lib/*.xz"   0644
# unpack "${OVERLAY_PATH}/lib64/*.xz" 0644
# unpack "${OVERLAY_PATH}/app/*/*.xz" 0644

# Create busybox links only for tools which are not in /system/bin
# as /vendor/bin is usually before in the PATH
if [ -e ${BB}_keep ]; then
	${BB} mkdir ${OVERLAY_PATH}/bb
	${BB} --install -s ${OVERLAY_PATH}/bb
	for file in ${OVERLAY_PATH}/bb/*; do
		cmd=${file##*/}
		for loc in /system/bin /system/sbin /system/xbin ${OVERLAY_PATH}/bin /sbin; do
			[ -e ${loc}/${cmd} ] && ${BB} rm ${file}
		done
	done
	${BB} mv ${OVERLAY_PATH}/bb/* ${OVERLAY_PATH}/bin/
	${BB} rmdir ${OVERLAY_PATH}/bb
	${BB} rm ${BB}_keep
else
	${BB} rm ${BB}
fi

for file in /vendor/lib/modules/*; do
	[ -e ${file} ] && ${BB} insmod ${file}
done

exit 0

#!/system/bin/sh

LOG=/boot.log

# GOVS: ONDEMAND, INTERACTIVE
CPUGOV=ONDEMAND

# mount rootfs writable
if mount | grep rootfs | grep -q ro; then
  mount -o rw,remount /
fi

# redirect logs
echo "init.cocore.post_boot: `date`" >> ${LOG}
echo "init.cocore.post_boot: ${CPUGOV}" >> ${LOG}
exec >> ${LOG} 2>&1

# bpf jit
echo 1 > /proc/sys/net/core/bpf_jit_enable

# uksm
echo full > /sys/kernel/mm/uksm/cpu_governor
echo 85 > /sys/kernel/mm/uksm/max_cpu_percentage
echo 1 > /sys/kernel/mm/uksm/run

# wled backlight segment threshold
# echo 0,150,18,1 > /sys/class/leds/wled\:backlight/seg

#
# cpufreq governor settings
#

# stop mpdecision service in case
stop mpdecision

# two-core touchboost offered by mpdecision
# this system property can adjust on the fly
#
# let user decide, for instance, via init.d etc etc
#
# setprop sys.somc.touch_perf_kick 0

echo 0 > /sys/module/msm_thermal/core_control/enabled

echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu2/online
echo 1 > /sys/devices/system/cpu/cpu3/online

if [ ${CPUGOV} = ONDEMAND ]; then
  echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  echo "ondemand" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
  echo "ondemand" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
  echo "ondemand" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

  echo 25000 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
  echo 90 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
  echo 1 > /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy
  echo 2 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
  echo 10 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential
  #
  # up_threshold_multi_core:
  #   Up threshold to increase to optimal freq when more than two cores are online
  #
  echo 80 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_multi_core
  echo 3 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential_multi_core
  echo 960000 > /sys/devices/system/cpu/cpufreq/ondemand/optimal_freq
  echo 729600 > /sys/devices/system/cpu/cpufreq/ondemand/sync_freq
  echo 80 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_any_cpu_load
elif [ ${CPUGOV} = INTERACTIVE ]; then
  echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  echo "interactive" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
  echo "interactive" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
  echo "interactive" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

  echo "10000 1800000:20000" > /sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay
  echo 90 > /sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load
  echo 1190400 > /sys/devices/system/cpu/cpufreq/interactive/hispeed_freq

  echo 1 > /sys/devices/system/cpu/cpufreq/interactive/io_is_busy

  echo "85 1500000:90 1800000:70" > /sys/devices/system/cpu/cpufreq/interactive/target_loads

  echo 10000 > /sys/devices/system/cpu/cpufreq/interactive/min_sample_time
  echo 20000 > /sys/devices/system/cpu/cpufreq/interactive/sampling_down_factor
  echo 10000 > /sys/devices/system/cpu/cpufreq/interactive/timer_rate
fi

echo 1 > /sys/module/msm_thermal/core_control/enabled

# enable multi-core scheduler
echo 2 > /sys/devices/system/cpu/sched_mc_power_savings

# invoke sysinit.d service
start sysinit

# wait for customized settings by user, allow to set for all CPUs
sleep 30

# start mpdecision service
start mpdecision


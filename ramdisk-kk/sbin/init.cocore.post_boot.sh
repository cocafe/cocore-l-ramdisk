#!/sbin/busybox sh

# UKSM
echo low > /sys/kernel/mm/uksm/cpu_governor

# Setup segments brightness for wled backlight
echo 0,150,18,1 > /sys/class/leds/wled\:backlight/seg

# Setup governor parameters and start mpdecision service
echo 0 > /sys/module/msm_thermal/core_control/enabled

echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu2/online
echo 1 > /sys/devices/system/cpu/cpu3/online

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
#       up_threshold_multi_core:
#	  Up threshold to increase to optimal freq when more than two cores are online
#
echo 80 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_multi_core
echo 3 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential_multi_core
echo 960000 > /sys/devices/system/cpu/cpufreq/ondemand/optimal_freq
echo 729600 > /sys/devices/system/cpu/cpufreq/ondemand/sync_freq
echo 80 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_any_cpu_load
# echo 1190000 > /sys/devices/system/cpu/cpufreq/ondemand/freq_input_boost

echo 1 > /sys/module/msm_thermal/core_control/enabled

# Enable Multi-core scheduler
echo 2 > /sys/devices/system/cpu/sched_mc_power_savings

# Wait for customized settings by user, allow to set all CPU governors
sleep 30
start mpdecision
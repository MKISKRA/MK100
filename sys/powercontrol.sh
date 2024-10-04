#!/bin/bash
#set -o nounset
#set -o errexit
LOG_FILE=$(date +"%d_%m_%Y")_powercontrol.log
LOG_FILE_PATH=/root/mk100/mk100t/logs/$LOG_FILE
exec > >(while read -r line; do printf '%s %s\n' "$(date --rfc-3339=seconds)" "$line" | tee -a $LOG_FILE_PATH; done)
exec 2> >(while read -r line; do printf '%s %s\n' "$(date --rfc-3339=seconds)" "$line" | tee -a $LOG_FILE_PATH; done >&2)

echo "powercontrol ver: 1.12"

CUR_BL=0
CUR_LP=0
CUR_BQC=0
ONLINE_CHARGER=0
CRIT_THERMAL="58900"
MESG_THERMAL="57900"
CNT_ARCH_LOGS=0


sleep_param()
{
	isl=0
	while [ $isl -le 9 ]
	do
		if (( $CUR_LP == 0 )); then
			CUR_BACKLIGHT=`cat /sys/class/backlight/backlight-dsi/brightness`
			#echo "CUR_BACKLIGHT: $CUR_BACKLIGHT"
			if (( $CUR_BACKLIGHT < 10 )); then
				if (( $CUR_BL != CUR_BACKLIGHT )); then
					CUR_BL=$CUR_BACKLIGHT
					echo 800000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
					echo 800000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
					echo 800000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
					echo 800000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq
					echo "RUN scaling_max_freq 800"
				fi
			else
				if (( $CUR_BL != CUR_BACKLIGHT )); then
					CUR_BL=$CUR_BACKLIGHT
					echo 1600000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
					echo 1600000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
					echo 1600000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
					echo 1600000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq
					echo "RUN scaling_max_freq 1600"
				fi
			fi
		fi
		((isl++))
		sleep 1
	done
}

archive_log()
{
	folder=/root/mk100/mk100t/logs
        pushd $folder
	ls -al
	date
	find -name "*.log" -ctime +0 -print
	readarray -t files < <(exec find -name "*.log" -ctime +0)
	for each in "${files[@]}"
	do
		echo "$each"
		#tar czf $folder/archive-powercontrol-log.tar.gz $each
		zip -u archive-powercontrol-log.zip $each
		rm "$each"
	done
	popd
	echo "archive_log"
}

get_data() {
	VOLTAGE_NOW=`cat /sys/class/power_supply/bq27520-0/voltage_now`
	echo "VOLTAGE_NOW: $VOLTAGE_NOW"
	STATUS=`cat /sys/class/power_supply/bq27520-0/status`
	echo "STATUS: $STATUS"
	CURRENT_NOW=`cat /sys/class/power_supply/bq27520-0/current_now`
	echo "CURRENT_NOW: $CURRENT_NOW"
	THERMAL_ZONE0=`cat /sys/class/thermal/thermal_zone0/temp`
	echo "THERMAL_ZONE0: $THERMAL_ZONE0"
	THERMAL_ZONE1=`cat /sys/class/thermal/thermal_zone1/temp`
	echo "THERMAL_ZONE1: $THERMAL_ZONE1"
	FILE_ONLINE_1=/sys/class/power_supply/bq25700-charger/online
	if [[ -f "$FILE_ONLINE_1" ]]; then
		ONLINE=`cat /sys/class/power_supply/bq25700-charger/online`
		echo "ONLINE: $ONLINE"
	fi
	FILE_ONLINE_2=/sys/class/power_supply/mp2669a_usb/online
	if [[ -f "$FILE_ONLINE_2" ]]; then
		ONLINE=`cat /sys/class/power_supply/mp2669a_usb/online`
		echo "ONLINE: $ONLINE"
	fi
}

is_charging()
{
	FILE_ONLINE_CHARGER_1=/sys/class/power_supply/bq25700-charger/online
	if [[ -f "$FILE_ONLINE_CHARGER_1" ]]; then
		ONLINE_CHARGER=`cat /sys/class/power_supply/bq25700-charger/online`
		echo "ONLINE_CHARGER: $ONLINE_CHARGER"
	fi
	FILE_ONLINE_CHARGER_2=/sys/class/power_supply/mp2669a_usb/online
	if [[ -f "$FILE_ONLINE_CHARGER_2" ]]; then
		ONLINE_CHARGER=`cat /sys/class/power_supply/mp2669a_usb/online`
		echo "ONLINE_CHARGER: $ONLINE_CHARGER"
	fi
	if (( $ONLINE_CHARGER == 0 )); then
		if (( $CUR_BQC > 0 )); then
			CUR_BQC=$(($CUR_BQC - 1))
		fi
	fi
	if (( $ONLINE_CHARGER == 1 )); then
		CUR_BQC=2
	fi

	echo "CUR_BQC: $CUR_BQC"
}

is_only_charging()
{
	FILE_ONLINE_CHARGER_1=/sys/class/power_supply/bq25700-charger/online
	if [[ -f "$FILE_ONLINE_CHARGER_1" ]]; then
		ONLINE_CHARGER=`cat /sys/class/power_supply/bq25700-charger/online`
		#echo "ONLINE_CHARGER: $ONLINE_CHARGER"
	fi
	FILE_ONLINE_CHARGER_2=/sys/class/power_supply/mp2669a_usb/online
	if [[ -f "$FILE_ONLINE_CHARGER_2" ]]; then
		ONLINE_CHARGER=`cat /sys/class/power_supply/mp2669a_usb/online`
		#echo "ONLINE_CHARGER: $ONLINE_CHARGER"
	fi

	if (( $ONLINE_CHARGER == 1 )); then
		CUR_BQC=2
	fi
}

get_thermal_critical() {
	if (( $CUR_BQC == 0 )); then
		THERMAL_ZONE_CHARGE=`cat /sys/class/thermal/thermal_zone1/temp`
		if [ $THERMAL_ZONE_CHARGE -ge $MESG_THERMAL ] ; then
			echo "Message Hi Thermal BQ."
			DISPLAY=:0 feh -F /usr/share/images/desktop-base/hightemperature.png &
			sleep 5
			pkill feh
		fi
	fi
}

is_archive()
{
	CNT_ARCH_LOGS=$(($CNT_ARCH_LOGS + 1))
	if (( $CNT_ARCH_LOGS > 60 )); then
		CNT_ARCH_LOGS=0
		archive_log
	fi
}

# Initialize the counter
archive_log
z=1
TIMEMESSG=30 # Show Period (sec) of message if CRITPWR (10 20 30 40 50 60)
# Iterate the loop for 2 times
while [ $z -le 2 ]
do
    FUNC=`cat /sys/kernel/debug/gpio | grep FUNC | awk '{print $1}' | awk -F '-' '{print $2}'` && echo $FUNC > /sys/class/gpio/export
    ONOFF=`cat /sys/kernel/debug/gpio | grep ONOFF | awk '{print $1}' | awk -F '-' '{print $2}'` && echo $ONOFF > /sys/class/gpio/export
    KKT_PRESENT=`cat /sys/kernel/debug/gpio | grep KKT_PRESENT | awk '{print $1}' | awk -F '-' '{print $2}'` && echo $KKT_PRESENT > /sys/class/gpio/export
    sleep 1
    chmod 1777 /tmp/.X11-unix
    z=$(($z + 1))
done

while :
do
	CURPWR=`cat /sys/class/power_supply/bq27520-0/voltage_now`
	MAXPWR="0"
	TIMECNTR=0
	CRITPWR="3200000"
	LOWPWR="3300000"
	LIMITPWR="3700000"

	for i in {1..6}
	do
		CURPWR=`cat /sys/class/power_supply/bq27520-0/voltage_now`
		#echo "Current power: $CURPWR"
		#get_data
		if [[ $CURPWR =~ ^[0-9]+$ ]] ; then
			if [ $CURPWR -gt $MAXPWR ] ; then
				MAXPWR=$CURPWR
				#echo "Max power: $MAXPWR"
			fi

			if [ $TIMECNTR -ge $TIMEMESSG ]; then
				#echo "TIMER MSG CRITICAL POWER"
				TIMECNTR=0
				get_thermal_critical
				if [ $LOWPWR -ge $MAXPWR ] ; then
					echo "MESSAGE CRITICAL POWER"
					DISPLAY=:0 feh -F /usr/share/images/desktop-base/criticalpower.png &
					sleep 5
					pkill feh
				fi
    			fi
		fi
		sleep_param
		is_only_charging
		TIMECNTR=$(($TIMECNTR + 10))
	done

	if [[ $MAXPWR =~ ^[0-9]+$ ]] ; then
		echo "-----------------------------------------"
		echo "Max power: $MAXPWR"
		get_data
		is_charging
		is_archive
		if [ $CRITPWR -ge $MAXPWR ] ; then
			echo "Critical Power."
			DISPLAY=:0 feh -F /usr/share/images/desktop-base/poweroff.png &
			sleep 10
			echo 1 > /sys/class/leds/charger_board_power_off/brightness
			poweroff
		fi
		if [ $LIMITPWR -ge $MAXPWR ] ; then
			echo 800000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
			echo 800000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
			echo 800000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
			echo 800000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq
			echo "RUN ALWAYS scaling_max_freq 800"
			CUR_LP=1
		else
			CUR_LP=0
			CUR_BL=0
		fi
	fi

 	sleep 5
done
# end

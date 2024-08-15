#!/bin/bash

# Initialize the counter
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

	for (( i=1; i <= 12; i++ ))
	do
		CURPWR=`cat /sys/class/power_supply/bq27520-0/voltage_now`
		#echo "Current power: $CURPWR"
		if [[ $CURPWR =~ ^[0-9]+$ ]] ; then
			if [ $CURPWR -gt $MAXPWR ] ; then
				MAXPWR=$CURPWR
				#echo "Max power: $MAXPWR"
			fi

			if [ $TIMECNTR -ge $TIMEMESSG ]; then
				#echo ">="
				TIMECNTR=0
				if [ $LOWPWR -ge $MAXPWR ] ; then
					DISPLAY=:0 feh -F /usr/share/images/desktop-base/criticalpower.png &
					sleep 5
					pkill feh
				fi
			else
			    #echo "<"
			fi
		fi
		sleep 10
		TIMECNTR=$(($TIMECNTR + 10))
	done

	if [[ $MAXPWR =~ ^[0-9]+$ ]] ; then

		echo "Max power ====: $MAXPWR"

		if [ $CRITPWR -ge $MAXPWR ] ; then
			echo "Critical Power."
			DISPLAY=:0 feh -F /usr/share/images/desktop-base/poweroff.png &
			sleep 10
			echo 1 > /sys/class/leds/charger_board_power_off/brightness
			poweroff
		fi

		#if [ $LOWPWR -ge $MAXPWR ] ; then
		#	DISPLAY=:0 feh -F /usr/share/images/desktop-base/criticalpower.png &
		#	sleep 5
		#	pkill feh
		#fi
	fi

 	sleep 5
done
# end

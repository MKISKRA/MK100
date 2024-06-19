#!/bin/bash

# Initialize the counter
z=1
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
	CRITPWR="3200000"
	LOWPWR="3300000"

	#echo "Current power: $CURPWR"

	if [[ $CURPWR =~ ^[0-9]+$ ]] ; then

		if [ $CRITPWR -ge $CURPWR ] ; then
			echo "Critical Power."	
			DISPLAY=:0 feh -F /usr/share/images/desktop-base/poweroff.png &
			sleep 10
			echo 1 > /sys/class/leds/charger_board_power_off/brightness
			poweroff
		fi

		if [ $LOWPWR -ge $CURPWR ] ; then
			DISPLAY=:0 feh -F /usr/share/images/desktop-base/criticalpower.png &
			sleep 5
			pkill feh
		fi
	fi

 	sleep 20
done
# end

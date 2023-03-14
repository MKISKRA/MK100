#!/bin/bash

FUNC=`cat /sys/kernel/debug/gpio | grep FUNC | awk '{print $1}' | awk -F '-' '{print $2}'` &&
how_many_touches=30
touch_detected=0
FILENAME=touchscreen_log.txt
SUB='0'
SLEEP_TOUCH='0'

while :
do

timeout 0.5s cat /dev/input/event0 > $FILENAME

var="$(cat /sys/class/gpio/gpio${FUNC}/value)"
if [[ "$var" == *"$SUB"* ]]; then
    let touch_detected=0
    echo 70 > /sys/class/backlight/backlight-dsi/brightness
    pkill evtest
    let SLEEP_TOUCH='0'
fi


if [ ! -s "${FILENAME}" ]; then
    let touch_detected=$touch_detected+1
#else
#    let touch_detected=0
#    echo 70 > /sys/class/backlight/backlight-dsi/brightness
#    pkill evtest
#    let SLEEP_TOUCH='0'
fi


if [ "$how_many_touches" -eq "$touch_detected" ]; then
    let touch_detected=0
    
    if [[ "$SLEEP_TOUCH" == *"$SUB"* ]]; then
    	let SLEEP_TOUCH='1'
    	echo 1 > /sys/class/backlight/backlight-dsi/brightness
    	evtest --grab /dev/input/event0 > /dev/null 2>&1 &
    fi
fi

done

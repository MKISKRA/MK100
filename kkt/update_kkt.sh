#!/bin/bash

DEV=/dev/ttymxc2
IS_OK="NO"
FRIMWARE="/root/mk100/MK100/kkt/prim05_STM_302_05.bin"

echo 0 > /sys/class/leds/charger_board_kkt_power/brightness
sleep 1
echo 1 > /sys/class/leds/charger_board_kkt_power/brightness

stty -F $DEV raw ispeed 115200 ospeed 115200 cs8 -ignpar -cstopb -echo 

x=1
while [ $x -le 30 ]
do
  echo "write space"
	
  echo -en '\x20' > $DEV
  sleep 0.1
  
  read -t 0.5 -n 1 character < $DEV
  echo $character
  
  if [[ "$character" == "C" ]]; then
  	IS_OK="OK"
  	break
  fi
  
  x=$(( $x + 1 ))
done

if [[ "$IS_OK" == "OK" ]]; then
	echo "write firmware"
	sz -v --ymodem $FRIMWARE > $DEV < $DEV
fi

echo "write OK"
sleep 5
exit 0

# ./ysend.sh prim05_ST_301_03.bin
# ./ysend.sh prim05_ST_301_07.bin

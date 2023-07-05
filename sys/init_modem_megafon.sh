#!/bin/sh -x

wait_dev()
{
	for cnt in `seq 1 $2`; do
		if [ -e "$1" ]; then
			break
		fi
		echo "wait $1"
		sleep 1
	done
}

trig_pwr_btn()
{
	sleep 1
	echo 1 > /sys/class/leds/gsm_pwr_key/brightness # pwrbutton press
	sleep 1
	echo 0 > /sys/class/leds/gsm_pwr_key/brightness # pwrbutton not pressed
}

dev=/dev/ttyUSB0

init_cmds()
{
#stty -F ${dev} raw 9600 || return
echo "TIMEOUT 5
'' 'ati'
'NEOWAY-ati-NEOWAY' ''
'OK' 'AT+NETSHAREMODE=1'
'OK' 'AT+CGDCONT=1,\"IP\",\"internet\"'
'OK' 'AT+NETSHAREACT=1,1,0'
'OK' 'AT\$MYGPSPWR=1'
'OK' ''" > /tmp/m.chat
chat -t 5 -V -f /tmp/m.chat <${dev} >${dev} 2>/tmp/m.out
}

date >> /tmp/init_modem.txt

if [ ! -e $dev ]; then
	trig_pwr_btn
	wait_dev $dev 30
	sleep 10
fi
systemctl stop ModemManager.service
systemctl stop gpsd.socket
sleep 1
init_cmds
systemctl start gpsd.socket
systemctl start ModemManager.service


#!/bin/sh

#get version hex
file_ver="ver.info" 
avaited_version=$(cat "$file_ver")      
echo "readed atiny fw version: $avaited_version"

# check is burned
v=`cat /sys/class/i2c-dev/i2c-2/device/2-0010/charger_board_ver`
echo "readed atiny fw version: $v"
#avaited_version="2.0.6"
if [ "$v" = "$avaited_version" ]; then
	echo "Already burned!!! (ok)"
	sleep 3
	exit 0
fi


AVR_RESET=`cat /sys/kernel/debug/gpio | grep AVR_RESET | awk '{print $1}' | awk -F '-' '{print $2}'`
AVR_SCK=`cat /sys/kernel/debug/gpio | grep AVR_SCK | awk '{print $1}' | awk -F '-' '{print $2}'`
AVR_MOSI=`cat /sys/kernel/debug/gpio | grep AVR_MOSI | awk '{print $1}' | awk -F '-' '{print $2}'`
AVR_MISO=`cat /sys/kernel/debug/gpio | grep AVR_MISO | awk '{print $1}' | awk -F '-' '{print $2}'`
AVR_I2C_DISABLE=`cat /sys/kernel/debug/gpio | grep AVR_I2C_DISABLE | awk '{print $1}' | awk -F '-' '{print $2}'`

echo ${AVR_RESET} > /sys/class/gpio/unexport
echo ${AVR_SCK} > /sys/class/gpio/unexport
echo ${AVR_MOSI} > /sys/class/gpio/unexport
echo ${AVR_MISO} > /sys/class/gpio/unexport
echo ${AVR_I2C_DISABLE} > /sys/class/gpio/unexport

d=`pwd`
cp ${d}/avrdude.conf /tmp/ # copy for edit
sed "s/reset = 488/reset = ${AVR_RESET}/g" -i /tmp/avrdude.conf
sed "s/sck   = 489/sck = ${AVR_SCK}/g" -i /tmp/avrdude.conf
sed "s/mosi  = 491/mosi = ${AVR_MOSI}/g" -i /tmp/avrdude.conf
sed "s/miso  = 490/miso = ${AVR_MISO}/g" -i /tmp/avrdude.conf

g=$AVR_I2C_DISABLE
echo $g > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$g/direction
echo 0 > /sys/class/gpio/gpio$g/value

#${d}/avrdude -C /tmp/avrdude.conf  -p t2313a -c pi_1 -P 1 -U
#avrdude: Device signature = 0x1e910a (probably t2313a)
#/mnt/store/avrdude -C avrdude.conf  -p t2313a -c pi_1 -P 1 -U flash:r:dump.hex:i
${d}/avrdude -C /tmp/avrdude.conf -P 0 -c pi_1 -p t2313a -v -U lfuse:w:${d}/lf.bin:r
${d}/avrdude -C /tmp/avrdude.conf -P 0 -c pi_1 -p t2313a -v -U efuse:w:${d}/ef.bin:r
${d}/avrdude -C /tmp/avrdude.conf -p t2313a -c pi_1 -P 1 -V -v -U flash:w:${d}/XC8_Charger.hex:i

echo 1 > /sys/class/gpio/gpio$g/value

echo "Success!"

sleep 3

exit 0
###


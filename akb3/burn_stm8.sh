#!/bin/sh

### burn stm8 in "accumulatornii modul"

mount -t debugfs debugfs /sys/kernel/debug
ONOFF=`cat /sys/kernel/debug/gpio | grep ONOFF | awk '{print $1}' | awk -F '-' '{print $2}'`
MUX_D=$((${ONOFF}+14)) #510
ENTER_TO_BOOTLOADER=$((${ONOFF}+15)) #511
AVR_RESET=`cat /sys/kernel/debug/gpio | grep AVR_RESET | awk '{print $1}' | awk -F '-' '{print $2}'`
echo "must be 510 511: $MUX_D $ENTER_TO_BOOTLOADER $AVR_RESET"

# MUX_C=1
echo 1 > /sys/class/leds/charger_board_ena_console_uart/brightness

# MUX_D=1
g=${MUX_D}
echo $g > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$g/direction
echo 1 > /sys/class/gpio/gpio$g/value

# ENTER_TO_BOOTLOADER = 1 ()
g=${ENTER_TO_BOOTLOADER}
echo $g > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$g/direction
echo 1 > /sys/class/gpio/gpio$g/value

#d=/mnt/store
STM8WD_SERIALDEV=/dev/ttymxc2 STM8WD_DEBUG=0 STM8WD_FWSREC=stm8_iskra_charger.srec STM8WD_FORCEUPDATE=true  ${d}./stm8wd

g=${AVR_RESET}
echo $g > /sys/class/gpio/export
echo low > /sys/class/gpio/gpio$g/direction
usleep 10000
echo in > /sys/class/gpio/gpio$g/direction

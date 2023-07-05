#!/bin/bash
echo 1 > /sys/class/leds/ena_bskpwr/brightness && export PYTHONPATH=/root/ir_examples_1.0.275633b && cd /root/ir_examples_1.0.275633b &&python3 irc.py -c /dev/ttymxc3 -b 115200 update_firmware /root/mk100/MK100/bsk/reader-1.38.5786.bin.P.signed

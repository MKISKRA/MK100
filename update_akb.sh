#!/bin/sh
cd /root/mk100t/firmwares/akb
chmod a+x avrdude burn_atiny.sh
./burn_atiny.sh
#Wait SUCCESS, ~350 seconds

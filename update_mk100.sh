#!/bin/bash
pkill MK100T; cd /root/mk100/MK100/ ; git fetch --all ; git reset --hard ; git pull; cp /root/mk100/MK100/MK100T /root/mk100/mk100t/MK100T; chmod +x /root/mk100/mk100t/MK100T;
cp /root/mk100/MK100/sys/data_print.cmd /root/mk100/mk100t/data_print.cmd;
cp /root/mk100/MK100/sys/libinput.rules /lib/udev/rules.d/libinput.rules;
cp /root/mk100/MK100/sys/gbutton /root/mk100/mk100t/gbutton;
cp /root/mk100/MK100/sys/sleep_screen.sh /root/mk100/mk100t/sleep_screen.sh;
cp /root/mk100/MK100/akb/XC8_Charger.hex /root/mk100/firmwares/akb/XC8_Charger.hex;
cp /root/mk100/MK100/akb/ver.info /root/mk100/firmwares/akb/ver.info
/root/mk100/mk100t/start.sh

#!/bin/bash
pkill MK100T; cd /root/mk100/MK100/ ; git fetch --all ; git reset --hard ; git pull; cp /root/mk100/MK100/MK100T /root/mk100/mk100t/MK100T; chmod +x /root/mk100/mk100t/MK100T;
cp /root/mk100/MK100/sys/bank.png /root/mk100/mk100t/bank.png;
cp /root/mk100/MK100/sys/data_print.cmd /root/mk100/mk100t/data_print.cmd;
cp /root/mk100/MK100/sys/bl_scan.sh /root/mk100/mk100t/bl_scan.sh;
cp /root/mk100/MK100/sys/ping.sh /root/mk100/mk100t/ping.sh;
cp /root/mk100/MK100/sys/speedtest.sh /root/mk100/mk100t/speedtest.sh;
cp /root/mk100/MK100/sys/init_modem_beeline.sh /root/mk100/mk100t/init_modem_beeline.sh;
cp /root/mk100/MK100/sys/init_modem_megafon.sh /root/mk100/mk100t/init_modem_megafon.sh;
cp /root/mk100/MK100/sys/init_modem_mts.sh /root/mk100/mk100t/init_modem_mts.sh;
cp /root/mk100/MK100/sys/init_modem_tele2.sh /root/mk100/mk100t/init_modem_tele2.sh;
cp /root/mk100/MK100/sys/libinput.rules /lib/udev/rules.d/libinput.rules;
cp /root/mk100/MK100/sys/gbutton /root/mk100/mk100t/gbutton;
cp /root/mk100/MK100/sys/sleep_screen.sh /root/mk100/mk100t/sleep_screen.sh;
cp /root/mk100/MK100/sys/mp2696_charger.ko /root/mp2696_charger.ko;
cd /;
/root/mk100/mk100t/start.sh

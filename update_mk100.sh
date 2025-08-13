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
cp /root/mk100/MK100/sys/criticalpower.png /usr/share/images/desktop-base/criticalpower.png;
cp /root/mk100/MK100/sys/criticaltemperature.png /usr/share/images/desktop-base/criticaltemperature.png;
cp /root/mk100/MK100/sys/hightemperature.png /usr/share/images/desktop-base/hightemperature.png;
cp /root/mk100/MK100/sys/poweroff.png /usr/share/images/desktop-base/poweroff.png;
# install ptu 0.53
sleep 1;
cd /root/mk100/;
echo "copy TPU 0.53";
cp -n /root/mk100/MK100/sys/tpu_0_53.zip /root/mk100/tpu_0_53.zip;
cp -n /root/mk100/MK100/sys/ca-certificates_20250419_all.deb /root/mk100/ca-certificates_20250419_all.deb;
cp -n /root/mk100/MK100/sys/tpucontrol.service /lib/systemd/system/tpucontrol.service;
cd /root/mk100/;
rm -r ./mk100t
unzip tpu_0_53.zip
dpkg -i ca-certificates_*_all.deb
update-ca-certificates
systemctl unmask tpucontrol.service
systemctl enable tpucontrol.service
systemctl start tpucontrol.service
#next install
cp /root/mk100/MK100/sys/powercontrol.sh /root/mk100/mk100t/powercontrol.sh; chmod +x /root/mk100/mk100t/powercontrol.sh;
systemctl restart powercontrol;
cd /;
chmod +x /root/mk100/mk100t/start.sh;
chmod +x /root/mk100/mk100t/MK100T;
/root/mk100/mk100t/start.sh

scp battery_charger_update username@host:/home/user 

#From debian
cd /home/user/battery_charger_update
chmod a+x avrdude burn_atiny.sh
./burn_atiny.sh

#Wait SUCCESS, ~350 seconds
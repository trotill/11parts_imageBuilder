#!bin/sh

killall node
sleep 5
mv /www/pages/necron/Cnoda/Cnoda* /
ln -s /Cnoda /www/pages/necron/Cnoda/Cnoda
ln -s /Cnoda.json /www/pages/necron/Cnoda/Cnoda.json
#!bin/sh

MODULE_NAME=<your module name>

#unlink /run/tw68

#killall scout-gst
modprobe -r $MODULE_NAME
modprobe $MODULE_NAME
#sleep 1


#scout-gst /dev/video0&
#echo 00150410 > /sys/class/video4linux/video0/md_conf
#echo /sys/class/video4linux/video0/passive_low
#echo 1 > /sys/class/video4linux/video2/passive_low

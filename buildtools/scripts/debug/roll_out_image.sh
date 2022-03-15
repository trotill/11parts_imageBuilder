#!bin/sh

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    echo "roll_out_image.sh <image> <device>"
    exit
fi

img_name=$1
device=/dev/sda

gunzip -c /$img_name | dd of=$device bs=32M status=progress

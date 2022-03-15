DEV=$1

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
else    
	echo DEV=$DEV
	sudo dd if=idbloader.img of=$DEV bs=512 seek=64
	sudo dd if=uboot.img of=$DEV bs=512 seek=24576
	sudo dd if=trust.img of=$DEV bs=512 seek=32768
	sync
fi
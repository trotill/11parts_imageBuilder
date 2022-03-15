dd if=VIM1.u-boot.sd.bin of=/dev/mmcblk? conv=fsync,notrunc bs=442 count=1
dd if=VIM1.u-boot.sd.bin of=/dev/mmcblk? conv=fsync,notrunc bs=512 skip=1 seek=1
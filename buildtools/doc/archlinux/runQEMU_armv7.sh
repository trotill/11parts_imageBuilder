qemu-system-arm -M orangepi-pc \
-nic user -no-reboot \
-nographic -kernel zImage \
-smp 4 \
-append 'console=ttyS0,115200 root=/dev/mmcblk0p1 rw' \
-dtb sun8i-h3-orangepi-pc.dtb \
-drive file=$1
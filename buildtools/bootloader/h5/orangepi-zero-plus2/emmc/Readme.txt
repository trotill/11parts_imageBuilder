Compile, need ATF

make BL31=./bl31.bin

Setup

dd if=u-boot-sunxi-with-spl.bin of=/dev/s bs=1024 seek=8 
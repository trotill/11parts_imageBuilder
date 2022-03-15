1. Load u-boot (host system)
../../../sunxi-tools/sunxi-fel uboot u-boot-sunxi-with-spl.bin write 0x42000000 u-boot-sunxi-with-spl.bin

2. Save u-boot
sf probe
sf erase 0 100000
sf write 42000000 0 100000
reset

OR

1. Write to spi flash 
../sunxi-tools/sunxi-fel -p spiflash-write 0 u-boot-sunxi-with-spl.bin

u-boot version 2020.04-rc3-dirty
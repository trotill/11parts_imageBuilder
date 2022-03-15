Setup
for 0x50
dd if=u-boot-sunxi-with-spl.bin of=/dev/s bs=1024 seek=8 

for 0x140
dd if=u-boot-sunxi-with-spl.bin of=/dev/s bs=1024 seek=128 

Write to emmc example
ext4load mmc 0:1 42000000 /uboot
mmc dev 1

mmc write 42000000 100 800//For 0x140
or
mmc write 42000000 10 800//For 0x40

u-boot config
смещение uboot для gpt с 8кб на 128кб
ENV_OFFSET=e0000
CONFIG_SYS_MMCSD_RAW_MODE_U_BOOT_SECTOR=0x140
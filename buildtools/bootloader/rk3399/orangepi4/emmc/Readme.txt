RK3399

u-boot шьется тремя файлами по смещениям как в скрипте flushUboot
консольный COM порт имеет скорость 1.5Мбод

Первый раздел должен начинатья по смещению 0xA000 (24Mб),
первые 20МБ диска заняты только u-boot 

Как собрать u-boot

1. Скачать его из denx.de
git clone https://gitlab.denx.de/u-boot/u-boot.git
собирать из под docker, с помощью ArchLinux, например archBuild
export ARCH=arm
export CROSS_COMPILE=/embedded/docker/archlinux/cross/prebuild/9.3.0-1/x-tools8/aarch64-unknown-linux-gnu/bin/aarch64-unknown-linux-gnu-
make orangepi-rk3399_defconfig
make

из всего должен быть собран только u-boot-dtb.bin, остальное лишнее


2. Скачать rkbin, с помощью него будет создан окончательный загрузчик!!!
git clone https://github.com/rockchip-linux/rkbin.git

Получаем idbloader.img
rkbin/tools/mkimage -n rk3399 -T rksd -d rkbin/bin/rk33/rk3399_ddr_933MHz_v1.24.bin idbloader.img
cat rkbin/bin/rk33/rk3399_miniloader_v1.26.bin >> idbloader.img

Подсовываем полученный u-boot и получаем uboot.img
rkbin/tools/loaderimage --pack --uboot v2021.01/u-boot-dtb.bin uboot.img 0x200000

Сборка trust.img, обязательно перейти в папку иначе не найдет
cd rkbin
tools/trust_merger RKTRUST/RK3399TRUST.ini
mv trust.img ../
cd ../

3. Шьем по смещениям (в пред версиях были другие, на 16Мб, а теперь на 20Мб)
dd if=/embedded/buildtools/buildtools/bootloader/rk3399/orangepi4/emmc/idbloader.img of=/dev/loop0 bs=512 seek=64
dd if=/embedded/buildtools/buildtools/bootloader/rk3399/orangepi4/emmc/uboot.img of=/dev/loop0 bs=512 seek=24576
dd if=/embedded/buildtools/buildtools/bootloader/rk3399/orangepi4/emmc/trust.bin of=/dev/loop0 bs=512 seek=32768



Как откл. emmc для загрузки с SD, например если зашит загрузчик с ошибкой.
Пинцетиком зажать TP50265 с падом конденсатора слева. TP находится на обратной стороне, в сантиметре от разьема SD, справа снизу
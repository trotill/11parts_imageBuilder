#!bin/sh

source initlib.sh

#Select one!!!
#make -C $KERNEL_PATH zImage -j4
#make -C $KERNEL_PATH bzImage -j4
#make -C $KERNEL_PATH Image.gz -j4
#make -C $KERNEL_PATH dtbs -j4
#make -C $KERNEL_PATH -modules -j4

echo "sync $KERNEL_PATH/arch/[zImage,uImage,Image] rootfs/boot/"
find $KERNEL_PATH/arch/ -iname Image.gz -o -iname Image -o -iname zImage -o -iname uImage -o -iname bzImage|xargs cp -t $PWD/boot/

echo "sync $KERNEL_PATH/arch/*.dtb rootfs/boot/"
find $KERNEL_PATH/arch/ -iname *.dtb|xargs cp -t $PWD/boot/




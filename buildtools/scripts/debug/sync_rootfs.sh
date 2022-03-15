#!bin/sh

source initlib.sh

mv ../rootfs/etc ../rootfs/etc_old
mv ../rootfs/boot ../rootfs/boot_old
mv ../rootfs/lib/modules ../rootfs/modules_old

echo "sync "$ORIGINAL_ROOTFS_PATH/* ../rootfs/
rsync -az $ORIGINAL_ROOTFS_PATH/* ../rootfs/
chown -R root.root ../rootfs/

rm -R ../rootfs/lib/modules
rm -R ../rootfs/etc
rm -R ../rootfs/boot
mv ../rootfs/modules_old ../rootfs/lib/modules
mv ../rootfs/etc_old ../rootfs/etc
mv ../rootfs/boot_old ../rootfs/boot
ls -l
echo "sync success"
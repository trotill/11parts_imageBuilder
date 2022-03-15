#!bin/sh

source /etc/necron/necron_image.conf

function status {
 sh $NECRON_STATUS_SCRIPT $1
}

function DeploySysSettings
{
  status "deploysys"
  umount /mnt
  mount -t $NECRON_FS_SYS_MOUNT_FS -o rw $NECRON_SYS_ROOT_DEVICE /mnt
  cp /etc/necron/*.set /mnt
  cp /etc/necron/*.crc /mnt
  umount /mnt
  mount -t $NECRON_FS_SYS_MOUNT_FS -o rw $NECRON_SYSEX_ROOT_DEVICE /mnt
  cp /etc/necron/*.set /mnt
  cp /etc/necron/*.crc /mnt
  umount /mnt
  sync
  status "deploysys_ok"
}

NECRON_FIT2_ROOT_DEVICE=$NECRON_FW_DEV_PATH_WSUFFIX"7"
echo Run factory handler, remove all data
status "backtofactory"
echo "Kill necron"
#while killall node 2>/dev/null; do sleep 1; done
killall node
sleep 20
killall svc
killall Cnoda
sleep 5
killall Cnoda -9
sleep 1
echo "Necron killed"

dd if=/dev/zero of=$NECRON_FIT2_ROOT_DEVICE bs=1M count=1

status "formatsys"
umount   $BASE_FOLDER$SYS_FOLDER
umount   $BASE_FOLDER$SYS_EX_FOLDER
umount ${TMP_DIR}/disks$SYS_FOLDER
umount ${TMP_DIR}/disks$SYS_EX_FOLDER
umount ${TMP_DIR}/disks/shared
umount  $BASE_FOLDER$DOWNLOAD_FOLDER
umount  $BASE_FOLDER$UPDATE_FOLDER
umount  $BASE_FOLDER$LOG_FOLDER

echo make fs  $NECRON_FS_SYS_MOUNT_FS "for" $NECRON_SYS_ROOT_DEVICE opts $NECRON_MKFS_SYS_OPTS
mkfs.$NECRON_FS_SYS_MOUNT_FS $NECRON_SYS_ROOT_DEVICE $NECRON_MKFS_SYS_OPTS
status "formatsys_ok"
status "formatsys_ex"
echo make fs  $NECRON_FS_SYS_MOUNT_FS "for" $NECRON_SYSEX_ROOT_DEVICE opts $NECRON_MKFS_SYS_OPTS
mkfs.$NECRON_FS_SYS_MOUNT_FS $NECRON_SYSEX_ROOT_DEVICE $NECRON_MKFS_SYS_OPTS
status "formatsys_ex_ok"
status "formatshared"
echo make fs  $NECRON_FS_SHARE_MOUNT_FS "for" $NECRON_SHARE_ROOT_DEVICE opts $NECRON_MKFS_SHARE_OPTS
mkfs.$NECRON_FS_SHARE_MOUNT_FS $NECRON_SHARE_ROOT_DEVICE $NECRON_MKFS_SHARE_OPTS
status "formatshared_ok"
status "backtofactory_ok"
#DeploySysSettings ""
reboot
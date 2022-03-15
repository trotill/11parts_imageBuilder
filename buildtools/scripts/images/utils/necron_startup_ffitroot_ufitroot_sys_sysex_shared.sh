#!bin/sh
#####################################################################NOT EDIT###################
#defaults
TMP_DIR=/var/run
BASE_FOLDER="/www/pages"
UPDATE_FOLDER="/update"
SYS_FOLDER="/sys"
SYS_EX_FOLDER="/sys_ex"
DOWNLOAD_FOLDER="/download"
LOG_FOLDER="/log"
NECRON_FOLDER="/necron"
CNODA_FOLDER=$BASE_FOLDER$NECRON_FOLDER/Cnoda
GFACTORY_UTIL=$CNODA_FOLDER/gprivate
UNDELETE_FILE="undelete.set"
UNDELETE_DIR=$BASE_FOLDER$UPDATE_FOLDER'/'$UNDELETE_FILE
UPDATE_MARKER="updated"
NECRON_DEFAULT_CFG_DIR="/etc/necron"
FACTORY_MARKER="image_is_factory"
UPDATER_MARKER="image_is_updater"
UPDATER_FILE_NAME_FROM_UPDATER="firmware.img"
if [ -z "$NECRON_FS_PART_TABLE" ]
then
  NECRON_FS_PART_TABLE="GPT"
fi
#defaults
#####################################################################NOT EDIT###################
source /etc/necron/necron_image.conf
source "/etc/necron/utils/necron_partitions_"$NECRON_IMAGE_TYPE".sh"

ifconfig lo up

function status {
 sh $NECRON_STATUS_SCRIPT $1
}



SOURCE_ROOT_DEVICE="/dev/sda1"

function GetSourceRootDevice {
 set -- $(cat /proc/cmdline)
 for x in "$@"; do
    case "$x" in
        root=*)
        echo "Source root device ${x#root=}"
  SOURCE_ROOT_DEVICE=${x#root=}
        ;;
    esac
 done

}

GetSourceRootDevice ""
status "run"

SOURCE_FW_DEV_PATH=sda
SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH
case $SOURCE_ROOT_DEVICE in
   /dev/mmcblk0p1)
      SOURCE_FW_DEV_PATH=/dev/mmcblk0
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH"p"
   ;;
   /dev/mmcblk1p1)
      SOURCE_FW_DEV_PATH=/dev/mmcblk1
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH"p"
   ;;
   /dev/mmcblk2p1)
      SOURCE_FW_DEV_PATH=/dev/mmcblk2
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH"p"
   ;;
   /dev/sda1)
      SOURCE_FW_DEV_PATH=/dev/sda
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH
   ;;
   /dev/sdb1)
      SOURCE_FW_DEV_PATH=/dev/sdb
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH
   ;;
   /dev/sdc1)
      SOURCE_FW_DEV_PATH=/dev/sdc
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH
   ;;
      /dev/mmcblk0p2)
      SOURCE_FW_DEV_PATH=/dev/mmcblk0
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH"p"
   ;;
   /dev/mmcblk1p2)
      SOURCE_FW_DEV_PATH=/dev/mmcblk1
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH"p"
   ;;
   /dev/mmcblk2p2)
      SOURCE_FW_DEV_PATH=/dev/mmcblk2
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH"p"
   ;;
   /dev/sda2)
      SOURCE_FW_DEV_PATH=/dev/sda
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH
   ;;
   /dev/sdb2)
      SOURCE_FW_DEV_PATH=/dev/sdb
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH
   ;;
   /dev/sdc2)
      SOURCE_FW_DEV_PATH=/dev/sdc
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH
   ;;
   #MBR
   /dev/mmcblk0p5)
      SOURCE_FW_DEV_PATH=/dev/mmcblk0
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH"p"
   ;;
   /dev/mmcblk1p5)
      SOURCE_FW_DEV_PATH=/dev/mmcblk1
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH"p"
   ;;
   /dev/mmcblk2p5)
      SOURCE_FW_DEV_PATH=/dev/mmcblk2
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH"p"
   ;;
   /dev/sda5)
      SOURCE_FW_DEV_PATH=/dev/sda
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH
   ;;
   /dev/sdb5)
      SOURCE_FW_DEV_PATH=/dev/sdb
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH
   ;;
   /dev/sdc5)
      SOURCE_FW_DEV_PATH=/dev/sdc
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH
   ;;
      /dev/mmcblk0p6)
      SOURCE_FW_DEV_PATH=/dev/mmcblk0
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH"p"
   ;;
   /dev/mmcblk1p6)
      SOURCE_FW_DEV_PATH=/dev/mmcblk1
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH"p"
   ;;
   /dev/mmcblk2p6)
      SOURCE_FW_DEV_PATH=/dev/mmcblk2
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH"p"
   ;;
   /dev/sda6)
      SOURCE_FW_DEV_PATH=/dev/sda
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH
   ;;
   /dev/sdb6)
      SOURCE_FW_DEV_PATH=/dev/sdb
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH
   ;;
   /dev/sdc6)
      SOURCE_FW_DEV_PATH=/dev/sdc
      SOURCE_FW_DEV_PATH_WSUFFIX=$SOURCE_FW_DEV_PATH
   ;;
esac

#папки текущей системы, с которой сейчас загружены
  SOURCE_FACTORY_ROOT_DEVICE=$SOURCE_FW_DEV_PATH_WSUFFIX$PNUM_FACT
  SOURCE_USER_ROOT_DEVICE=$SOURCE_FW_DEV_PATH_WSUFFIX$PNUM_USER
  SOURCE_SYS_ROOT_DEVICE=$SOURCE_FW_DEV_PATH_WSUFFIX$PNUM_SYS
  SOURCE_SYSEX_ROOT_DEVICE=$SOURCE_FW_DEV_PATH_WSUFFIX$PNUM_SYSEX
  SOURCE_SHARE_ROOT_DEVICE=$SOURCE_FW_DEV_PATH_WSUFFIX$PNUM_SHARED
  SOURCE_FIT1_ROOT_DEVICE=$SOURCE_FW_DEV_PATH_WSUFFIX$PNUM_FFIT
  SOURCE_FIT2_ROOT_DEVICE=$SOURCE_FW_DEV_PATH_WSUFFIX$PNUM_UFIT

echo FS_PART_TABLE $NECRON_FS_PART_TABLE

echo Source FACTORY_ROOT_DEVICE $SOURCE_FACTORY_ROOT_DEVICE Dest $NECRON_FACTORY_ROOT_DEVICE
echo Source USER_ROOT_DEVICE $SOURCE_USER_ROOT_DEVICE Dest $NECRON_USER_ROOT_DEVICE
echo Source SYS_ROOT_DEVICE $SOURCE_SYS_ROOT_DEVICE Dest $NECRON_SYS_ROOT_DEVICE
echo Source SYSEX_ROOT_DEVICE $SOURCE_SYSEX_ROOT_DEVICE Dest $NECRON_SYSEX_ROOT_DEVICE
echo Source SHARE_ROOT_DEVICE $SOURCE_SHARE_ROOT_DEVICE Dest $NECRON_SHARE_ROOT_DEVICE
echo Source FIT1_ROOT_DEVICE $SOURCE_FIT1_ROOT_DEVICE Dest $NECRON_FIT1_ROOT_DEVICE
echo Source FIT2_ROOT_DEVICE $SOURCE_FIT2_ROOT_DEVICE Dest $NECRON_FIT2_ROOT_DEVICE

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

function ClonePartitions
{
#function
#

  #  FillImage_ffitroot_ufitroot_sys_sysex_shared  $SOURCE_FW_DEV_PATH $SOURCE_FIT_FW_PATH $NECRON_FW_DEV_PATH
  echo Clone Root patition
  #status "removefit"
  #dd if=/dev/zero of=$NECRON_FIT1_ROOT_DEVICE
  #bs=$NECRON_TARGET_SYS_MAX_SIZE_IN_BYTES count=1
  #dd if=/dev/zero of=$NECRON_FIT2_ROOT_DEVICE
  #bs=$NECRON_TARGET_SYS_MAX_SIZE_IN_BYTES count=1
  #status "removefit_ok"

  status "clonepartitions"
  #echo dd if=$SOURCE_FACTORY_ROOT_DEVICE of=$NECRON_FACTORY_ROOT_DEVICE
  #dd if=$SOURCE_FACTORY_ROOT_DEVICE of=$NECRON_FACTORY_ROOT_DEVICE
  #echo dd if=$SOURCE_FIT1_ROOT_DEVICE of=$NECRON_FIT1_ROOT_DEVICE
  #dd if=$SOURCE_FIT1_ROOT_DEVICE of=$NECRON_FIT1_ROOT_DEVICE 


  echo dd if=/dev/zero of=$NECRON_FIT1_ROOT_DEVICE bs=1M count=1
  dd if=/dev/zero of=$NECRON_FIT1_ROOT_DEVICE bs=1M count=1

  echo dd if=/dev/zero of=$NECRON_FIT2_ROOT_DEVICE bs=1M count=1
  dd if=/dev/zero of=$NECRON_FIT2_ROOT_DEVICE bs=1M count=1

  echo make fs  $NECRON_FS_SYS_MOUNT_FS "for" $NECRON_SYS_ROOT_DEVICE opts $NECRON_MKFS_SYS_OPTS
  mkfs.$NECRON_FS_SYS_MOUNT_FS $NECRON_SYS_ROOT_DEVICE $NECRON_MKFS_SYS_OPTS
  
  echo make fs  $NECRON_FS_SYS_MOUNT_FS "for" $NECRON_SYSEX_ROOT_DEVICE opts $NECRON_MKFS_SYS_OPTS
  mkfs.$NECRON_FS_SYS_MOUNT_FS $NECRON_SYSEX_ROOT_DEVICE $NECRON_MKFS_SYS_OPTS
  echo make fs  $NECRON_FS_SHARE_MOUNT_FS "for" $NECRON_SHARE_ROOT_DEVICE opts $NECRON_MKFS_SHARE_OPTS
  mkfs.$NECRON_FS_SHARE_MOUNT_FS $NECRON_SHARE_ROOT_DEVICE $NECRON_MKFS_SHARE_OPTS

  #mount $NECRON_SHARE_ROOT_DEVICE /mnt
  #mkdir /mnt/update
  #mount --bind /mnt/update $BASE_FOLDER$UPDATE_FOLDER
  echo $CNODA_FOLDER/imcheck /www/pages/download/$UPDATER_FILE_NAME_FROM_UPDATER $BASE_FOLDER$UPDATE_FOLDER firmware update $TMP_DIR
  $CNODA_FOLDER/imcheck /www/pages/download/$UPDATER_FILE_NAME_FROM_UPDATER $BASE_FOLDER$UPDATE_FOLDER firmware update $TMP_DIR
  #umount /mnt/update
  #umount $NECRON_SHARE_ROOT_DEVICE
  status "clonepartitions_ok"
  DeploySysSettings ""
}

function CreatePartitions
{
    #$1 storage device
    device=$1
    status "createpartitions"
  let "rootfs_partition_size_in_blocks=NECRON_TARGET_ROOTFS_MAX_SIZE_IN_BYTES/NECRON_TARGET_SECTOR_SIZE"
  let "fit_partition_size_in_blocks=NECRON_TARGET_FIT_MAX_SIZE_IN_BYTES/NECRON_TARGET_SECTOR_SIZE"
  let "sys_partition_size_in_blocks=NECRON_TARGET_SYS_MAX_SIZE_IN_BYTES/NECRON_TARGET_SECTOR_SIZE"
  let "storage_size_in_blocks=rootfs_partition_size_in_blocks*4"
  let "rootfs_size_in_blocks=rootfs_partition_size_in_blocks-(rootfs_partition_size_in_blocks/10)"

    CreatePartitions_$NECRON_IMAGE_TYPE $NECRON_TARGET_SECTOR_SIZE $rootfs_partition_size_in_blocks $fit_partition_size_in_blocks $sys_partition_size_in_blocks $storage_size_in_blocks $device
    MODIFY_MBR_GPT ""
    status "createpartitions_ok"
}

function FSCK
{
    fs=$1
    dev=$2
    case $fs in
    ext4)
        fsck.ext4 $dev -y
        fsck.ext4 $dev -p
    ;;
    ext3)
        fsck.ext3 $dev -y
        fsck.ext3 $dev -p
    ;;
    ext2)
        fsck.ext2 $dev -y
        fsck.ext2 $dev -p
    ;;
   esac
}

function PrepareNecron
{
  #$1 SYS dev
  #$2 SYS_EX dev
  #$3 SHARE dev

  SYS_ROOT_DEVICE=$1
  SYSEX_ROOT_DEVICE=$2
  SHARE_ROOT_DEVICE=$3

  status "preparenecron"

  install -d ${TMP_DIR}/disks/sys ${TMP_DIR}/disks/sys_ex ${TMP_DIR}/disks/shared/download ${TMP_DIR}/disks/shared/update ${TMP_DIR}/disks/shared/log

  umount ${TMP_DIR}/disks$SYS_FOLDER 2>/dev/zero
  umount ${TMP_DIR}/disks$SYS_EX_FOLDER 2>/dev/zero
  umount ${TMP_DIR}/disks/shared 2>/dev/zero
  umount   $BASE_FOLDER$SYS_FOLDER 2>/dev/zero
  umount   $BASE_FOLDER$SYS_EX_FOLDER 2>/dev/zero
  umount   $BASE_FOLDER$DOWNLOAD_FOLDER 2>/dev/zero
  umount   $BASE_FOLDER$UPDATE_FOLDER 2>/dev/zero
  umount   $BASE_FOLDER$LOG_FOLDER 2>/dev/zero
  umount   $BASE_FOLDER$NECRON_FOLDER 2>/dev/zero

  status "checknrepairfs"
  FSCK $NECRON_FS_SYS_MOUNT_FS $SYS_ROOT_DEVICE
  FSCK $NECRON_FS_SYS_MOUNT_FS $SYSEX_ROOT_DEVICE
  FSCK $NECRON_FS_SHARE_MOUNT_FS $SHARE_ROOT_DEVICE
  status "checknrepairfs_ok"

  echo   mount -t $NECRON_FS_SYS_MOUNT_FS -o $NECRON_FS_SYS_MOUNT_OPTS $SYS_ROOT_DEVICE ${TMP_DIR}/disks/$SYS_FOLDER
  mount -t $NECRON_FS_SYS_MOUNT_FS -o $NECRON_FS_SYS_MOUNT_OPTS $SYS_ROOT_DEVICE ${TMP_DIR}/disks/$SYS_FOLDER

  echo  mount -t $NECRON_FS_SYS_MOUNT_FS -o $NECRON_FS_SYS_MOUNT_OPTS $SYSEX_ROOT_DEVICE ${TMP_DIR}/disks/$SYS_EX_FOLDER
  mount -t $NECRON_FS_SYS_MOUNT_FS -o $NECRON_FS_SYS_MOUNT_OPTS $SYSEX_ROOT_DEVICE ${TMP_DIR}/disks/$SYS_EX_FOLDER

  RESIZE_SHARE_PARTITION ""
  echo  mount -t $NECRON_FS_SHARE_MOUNT_FS -o $NECRON_FS_SHARE_MOUNT_OPTS $SHARE_ROOT_DEVICE ${TMP_DIR}/disks/shared
  mount -t $NECRON_FS_SHARE_MOUNT_FS -o $NECRON_FS_SHARE_MOUNT_OPTS $SHARE_ROOT_DEVICE ${TMP_DIR}/disks/shared
  mount_sys_st=$(cat /proc/mounts|grep $SYS_ROOT_DEVICE)
  mount_sysex_st=$(cat /proc/mounts|grep $SYSEX_ROOT_DEVICE)
  mount_shared_st=$(cat /proc/mounts|grep $SHARE_ROOT_DEVICE)

  if [ -z "$mount_sys_st" ]
  then
     echo SYS incorrect make fs  $NECRON_FS_SYS_MOUNT_FS "for" $SYS_ROOT_DEVICE opts $NECRON_MKFS_SYS_OPTS
     mkfs.$NECRON_FS_SYS_MOUNT_FS $SYS_ROOT_DEVICE $NECRON_MKFS_SYS_OPTS
     mount -t $NECRON_FS_SYS_MOUNT_FS -o $NECRON_FS_SYS_MOUNT_OPTS $SYS_ROOT_DEVICE ${TMP_DIR}/disks/$SYS_FOLDER
  fi

  if [ -z "$mount_sysex_st" ]
  then
     echo SYSEX incorrect make fs  $NECRON_FS_SYS_MOUNT_FS "for" $SYSEX_ROOT_DEVICE opts $NECRON_MKFS_SYS_OPTS
     mkfs.$NECRON_FS_SYS_MOUNT_FS $SYSEX_ROOT_DEVICE $NECRON_MKFS_SYS_OPTS
     mount -t $NECRON_FS_SYS_MOUNT_FS -o $NECRON_FS_SYS_MOUNT_OPTS $SYSEX_ROOT_DEVICE ${TMP_DIR}/disks/$SYS_EX_FOLDER
  fi

  if [ -z "$mount_shared_st" ]
  then
     echo SHARED incorrect make fs  $NECRON_FS_SHARE_MOUNT_FS "for" $SHARE_ROOT_DEVICE opts $NECRON_MKFS_SHARE_OPTS
     mkfs.$NECRON_FS_SHARE_MOUNT_FS $SHARE_ROOT_DEVICE $NECRON_MKFS_SHARE_OPTS
     mount -t $NECRON_FS_SHARE_MOUNT_FS -o $NECRON_FS_SHARE_MOUNT_OPTS $SHARE_ROOT_DEVICE ${TMP_DIR}/disks/shared
  fi


  if [ ! -d "${TMP_DIR}/disks/shared/$UPDATE_FOLDER" ]; then
    install -d ${TMP_DIR}/disks/shared$UPDATE_FOLDER
    echo "Install update folder"
  fi
  if [ ! -d "${TMP_DIR}/disks/shared/$DOWNLOAD_FOLDER" ]; then
    install -d ${TMP_DIR}/disks/shared$DOWNLOAD_FOLDER
    echo "Install download folder"
  fi
  if [ ! -d "${TMP_DIR}/disks/shared$LOG_FOLDER" ]; then
    install -d ${TMP_DIR}/disks/shared$LOG_FOLDER
    echo "Install log folder"
  fi
  #Mount ${TMP_DIR}/disks/sys $NECRON_SYS_ROOT_DEVICE
  #Mount ${TMP_DIR}/disks/sys_ex $NECRON_SYSEX_ROOT_DEVICE
  #Mount ${TMP_DIR}/disks/shared $NECRON_SHARE_ROOT_DEVICE

  install -d $BASE_FOLDER$SYS_FOLDER $BASE_FOLDER$SYS_EX_FOLDER $BASE_FOLDER$DOWNLOAD_FOLDER $BASE_FOLDER$UPDATE_FOLDER $BASE_FOLDER$LOG_FOLDER $BASE_FOLDER$NECRON_FOLDER
  mount --bind $TMP_DIR/disks$SYS_FOLDER $BASE_FOLDER$SYS_FOLDER
  mount --bind $TMP_DIR/disks$SYS_EX_FOLDER $BASE_FOLDER$SYS_EX_FOLDER 2>/dev/zero
  mount --bind $TMP_DIR/disks/shared$DOWNLOAD_FOLDER $BASE_FOLDER$DOWNLOAD_FOLDER 2>/dev/zero
  mount --bind $TMP_DIR/disks/shared$UPDATE_FOLDER $BASE_FOLDER$UPDATE_FOLDER 2>/dev/zero
  mount --bind $TMP_DIR/disks/shared$LOG_FOLDER $BASE_FOLDER$LOG_FOLDER 2>/dev/zero
  mount --bind $NECRON_PATH $BASE_FOLDER$NECRON_FOLDER 2>/dev/zero

}

function CheckUserUpdate
{
    status "checkupd"
    echo check "$BASE_FOLDER$UPDATE_FOLDER/$UPDATE_MARKER"
    if [ -f "$BASE_FOLDER$UPDATE_FOLDER/$UPDATE_MARKER" ]; then
        status "foundupdmarker"
        echo "Found update marker"
        echo "Umount sys, sys_ex and create new partitions"
        umount   $BASE_FOLDER$SYS_FOLDER
        umount   $BASE_FOLDER$SYS_EX_FOLDER
        umount ${TMP_DIR}/disks$SYS_FOLDER
        umount ${TMP_DIR}/disks$SYS_EX_FOLDER
        status "formatsys"
        echo make fs  $NECRON_FS_SYS_MOUNT_FS "for" $NECRON_SYS_ROOT_DEVICE opts $NECRON_MKFS_SYS_OPTS
        mkfs.$NECRON_FS_SYS_MOUNT_FS $NECRON_SYS_ROOT_DEVICE $NECRON_MKFS_SYS_OPTS
        echo make fs  $NECRON_FS_SYS_MOUNT_FS "for" $NECRON_SYSEX_ROOT_DEVICE opts $NECRON_MKFS_SYS_OPTS
        mkfs.$NECRON_FS_SYS_MOUNT_FS $NECRON_SYSEX_ROOT_DEVICE $NECRON_MKFS_SYS_OPTS
        status "formatsys_ok"
        echo "Mount new partitions sys, sys_ex"
        status "mountsys"
        mount -t $NECRON_FS_SYS_MOUNT_FS -o $NECRON_FS_SYS_MOUNT_OPTS $NECRON_SYS_ROOT_DEVICE ${TMP_DIR}/disks/$SYS_FOLDER
        mount -t $NECRON_FS_SYS_MOUNT_FS -o $NECRON_FS_SYS_MOUNT_OPTS $NECRON_SYSEX_ROOT_DEVICE ${TMP_DIR}/disks/$SYS_EX_FOLDER
        mount --bind $TMP_DIR/disks$SYS_FOLDER $BASE_FOLDER$SYS_FOLDER
        mount --bind $TMP_DIR/disks$SYS_EX_FOLDER $BASE_FOLDER$SYS_EX_FOLDER
        status "mountsys_ok"

        status "copydefault"
        
        #echo cp $NECRON_DEFAULT_CFG_DIR'/'*.set $BASE_FOLDER$SYS_FOLDER
        #echo cp $NECRON_DEFAULT_CFG_DIR'/'*.set $BASE_FOLDER$SYS_EX_FOLDER
        #echo cp $NECRON_DEFAULT_CFG_DIR'/'*.crc $BASE_FOLDER$SYS_FOLDER
        #echo cp $NECRON_DEFAULT_CFG_DIR'/'*.crc $BASE_FOLDER$SYS_EX_FOLDER

        cp $NECRON_DEFAULT_CFG_DIR'/'*.set $BASE_FOLDER$SYS_FOLDER
        cp $NECRON_DEFAULT_CFG_DIR'/'*.set $BASE_FOLDER$SYS_EX_FOLDER
        cp $NECRON_DEFAULT_CFG_DIR'/'*.crc $BASE_FOLDER$SYS_FOLDER
        cp $NECRON_DEFAULT_CFG_DIR'/'*.crc $BASE_FOLDER$SYS_EX_FOLDER
        status "copydefault_ok"
        echo "Copy undelete files to sys, sys_ex" cp -ard "$UNDELETE_DIR/*" $BASE_FOLDER$SYS_FOLDER
        status "copyundel"
        cp -ard $UNDELETE_DIR/* $BASE_FOLDER$SYS_FOLDER
        cp -ard $UNDELETE_DIR/* $BASE_FOLDER$SYS_EX_FOLDER
        status "copyundel_ok"
        sync
        mount  ${TMP_DIR}/disks/$SYS_FOLDER -o remount
        mount  ${TMP_DIR}/disks/$SYS_EX_FOLDER -o remount
        echo "Save "$UPDATE_MARKER
        cp $BASE_FOLDER$UPDATE_FOLDER'/'$UPDATE_MARKER ${TMP_DIR}
        status "formatshared"
        echo "Umount shared and create new partitions"
        umount ${TMP_DIR}/disks/shared
        umount  $BASE_FOLDER$DOWNLOAD_FOLDER
        umount  $BASE_FOLDER$UPDATE_FOLDER
        umount  $BASE_FOLDER$LOG_FOLDER

        
        if [ -z $NATIVE_IMAGE_SHARE_PARTITION_SKIP_MKFS ]
        then
          NATIVE_IMAGE_SHARE_PARTITION_SKIP_MKFS="0"
        fi

        if [ "0" -eq $NATIVE_IMAGE_SHARE_PARTITION_SKIP_MKFS ]
        then
          echo make fs  $NECRON_FS_SHARE_MOUNT_FS "for" $NECRON_SHARE_ROOT_DEVICE opts $NECRON_MKFS_SHARE_OPTS
          mkfs.$NECRON_FS_SHARE_MOUNT_FS $NECRON_SHARE_ROOT_DEVICE $NECRON_MKFS_SHARE_OPTS
          status "formatshared_ok"
          echo "Mount new partitions shared for $DOWNLOAD_FOLDER $UPDATE_FOLDER $LOG_FOLDER"
        else
           echo "Skip format shared, options disabled"
        fi

        status "mountshared"
        mount -t $NECRON_FS_SHARE_MOUNT_FS -o $NECRON_FS_SHARE_MOUNT_OPTS $NECRON_SHARE_ROOT_DEVICE ${TMP_DIR}/disks/shared
        install -d ${TMP_DIR}/disks/shared$UPDATE_FOLDER
        install -d ${TMP_DIR}/disks/shared$DOWNLOAD_FOLDER
        install -d ${TMP_DIR}/disks/shared$LOG_FOLDER

        mount --bind $TMP_DIR/disks/shared$DOWNLOAD_FOLDER $BASE_FOLDER$DOWNLOAD_FOLDER
        mount --bind $TMP_DIR/disks/shared$UPDATE_FOLDER $BASE_FOLDER$UPDATE_FOLDER
        mount --bind $TMP_DIR/disks/shared$LOG_FOLDER $BASE_FOLDER$LOG_FOLDER
        status "mountshared_ok"
        echo "Copy marker to sys, sys_ex"
        status "copymarker"
        cp -ard ${TMP_DIR}/$UPDATE_MARKER $BASE_FOLDER$SYS_FOLDER
        cp -ard ${TMP_DIR}/$UPDATE_MARKER $BASE_FOLDER$SYS_EX_FOLDER
        status "copymarker_ok"
        if [ "1" -eq $NATIVE_IMAGE_SHARE_PARTITION_SKIP_MKFS ]
        then
          rm $BASE_FOLDER$UPDATE_FOLDER/$UPDATE_MARKER
          echo "Skip format shared, remove update marker"
        fi
    fi
    status "checkupd_ok"
}

function RunNecron
{
  ifconfig lo up
  status "runnecron"
  /www/pages/necron/Cnoda/necron /www/pages/necron/Cnoda/Cnoda.json&
}

function BootFromUpdateDevice {
 echo boot from update device
 touch ${TMP_DIR}/${UPDATER_MARKER}
 CreatePartitions $NECRON_FW_DEV_PATH
 PrepareNecron $SOURCE_SYS_ROOT_DEVICE $SOURCE_SYSEX_ROOT_DEVICE $SOURCE_SHARE_ROOT_DEVICE
 ClonePartitions ""

}

if [ $NECRON_FACTORY_ROOT_DEVICE == $SOURCE_ROOT_DEVICE ]
then
 status "bootfact"
  echo boot from target factory device
  PrepareNecron $NECRON_SYS_ROOT_DEVICE $NECRON_SYSEX_ROOT_DEVICE $NECRON_SHARE_ROOT_DEVICE
  $GFACTORY_UTIL
  touch ${TMP_DIR}/${FACTORY_MARKER}
  RunNecron ""
else
 if [ $NECRON_USER_ROOT_DEVICE == $SOURCE_ROOT_DEVICE ]
 then
  status "bootuser"
  echo boot from target user device
  PrepareNecron $NECRON_SYS_ROOT_DEVICE $NECRON_SYSEX_ROOT_DEVICE $NECRON_SHARE_ROOT_DEVICE
  CheckUserUpdate ""
  $GFACTORY_UTIL
  RunNecron ""
 else
   status "bootupdate"
    #echo BootFromUpdateDevice
   

   BootFromUpdateDevice ""
   $GFACTORY_UTIL "noreboot"
   while [ 1 ]
    do
        echo Update ready. Please power off, after remove updater and boot device
        status "bootupdate_ok"
        sleep 1
    done
 fi
fi

status "exit_ok"

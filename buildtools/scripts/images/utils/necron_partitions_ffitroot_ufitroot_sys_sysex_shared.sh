##!/bin/sh

if [ -z "$NECRON_FS_PART_TABLE" ]
then
  NECRON_FS_PART_TABLE="GPT"
fi

if [[ "MBR" == "$NECRON_FS_PART_TABLE" ]];
then
  echo SELECT MBR mode
  PNUM_FFIT=10
  PNUM_FACT=5
  PNUM_UFIT=11
  PNUM_USER=6
  PNUM_SYS=7
  PNUM_SYSEX=8
  PNUM_SHARED=9
  PNUM_EFI=12
  NECRON_FACTORY_ROOT_DEVICE=$NECRON_FW_DEV_PATH_WSUFFIX"5"
  NECRON_USER_ROOT_DEVICE=$NECRON_FW_DEV_PATH_WSUFFIX"6"
  NECRON_SYS_ROOT_DEVICE=$NECRON_FW_DEV_PATH_WSUFFIX"7"
  NECRON_SYSEX_ROOT_DEVICE=$NECRON_FW_DEV_PATH_WSUFFIX"8"
  NECRON_SHARE_ROOT_DEVICE=$NECRON_FW_DEV_PATH_WSUFFIX"9"
  NECRON_FIT1_ROOT_DEVICE=$NECRON_FW_DEV_PATH_WSUFFIX"10"
  NECRON_FIT2_ROOT_DEVICE=$NECRON_FW_DEV_PATH_WSUFFIX"11"
else
  echo SELECT GPT mode
  PNUM_FFIT=6
  PNUM_FACT=1
  PNUM_UFIT=7
  PNUM_USER=2
  PNUM_SYS=3
  PNUM_SYSEX=4
  PNUM_SHARED=5
  PNUM_EFI=8
  NECRON_FACTORY_ROOT_DEVICE=$NECRON_FW_DEV_PATH_WSUFFIX"1"
  NECRON_USER_ROOT_DEVICE=$NECRON_FW_DEV_PATH_WSUFFIX"2"
  NECRON_SYS_ROOT_DEVICE=$NECRON_FW_DEV_PATH_WSUFFIX"3"
  NECRON_SYSEX_ROOT_DEVICE=$NECRON_FW_DEV_PATH_WSUFFIX"4"
  NECRON_SHARE_ROOT_DEVICE=$NECRON_FW_DEV_PATH_WSUFFIX"5"
  NECRON_FIT1_ROOT_DEVICE=$NECRON_FW_DEV_PATH_WSUFFIX"6"
  NECRON_FIT2_ROOT_DEVICE=$NECRON_FW_DEV_PATH_WSUFFIX"7"
fi


function CreateZeroImage_ffitroot_ufitroot_sys_sysex_shared {
  #$1 - sector size
  #$2 - storage size

  unit_size=$1
  storage_size=$2
  dd if=/dev/zero of=$zeroimagename count=$storage_size bs=$unit_size
  echo dd if=/dev/zero of=$zeroimagename count=$storage_size bs=$unit_size

}

function GenZeroImage_ffitroot_ufitroot_sys_sysex_shared {
  #$1 - sector size
  #$2 - rootfs max size in sectors
  #$3 - fdt max size in sectors
  #$4 - sys max size in sectors
  #$5 - storage max size in sectors
  #$6 - image name
  unit_size=$1
  rootfs_size=$2
  fdt_size=$3
  sys_size=$4
  storage_size=$5
  zeroimagename=$6

  CreateZeroImage_ffitroot_ufitroot_sys_sysex_shared $unit_size $storage_size $zeroimagename
  CreatePartitions_ffitroot_ufitroot_sys_sysex_shared $1 $2 $3 $4 $5 $6
}

function CreatePartitions_ffitroot_ufitroot_sys_sysex_shared {
  if [[ "MBR" == "$NECRON_FS_PART_TABLE" ]];
  then
    CreatePartitions_ffitroot_ufitroot_sys_sysex_sharedMBR $1 $2 $3 $4 $5 $6
  else
    CreatePartitions_ffitroot_ufitroot_sys_sysex_sharedGPT $1 $2 $3 $4 $5 $6
  fi
}

function CreatePartitions_ffitroot_ufitroot_sys_sysex_sharedMBR {
  #$1 - sector size
  #$2 - rootfs max size in sectors
  #$3 - fdt max size in sectors
  #$4 - sys max size in sectors
  #$5 - storage max size in sectors
  #$6 - image name  
 
  mb=1048576
  #skip_sectors=8192
  if [ -z $PART_OFFSET ]; then 
    skip_sectors=8192
  else
    let "skip_sectors=PART_OFFSET/512"
  fi

  unit_size=$1
  rootfs_size=$2 #rootfs_size в блоках unit_size

  let "PART_OFFSET=$skip_sectors*$unit_size"
  echo PART_OFFSET $PART_OFFSET
  
  let "rootfs_size_mb=(rootfs_size*unit_size)/mb"
  echo "rootfs_size" $rootfs_size "rootfs_size_mb" $rootfs_size_mb
  fdt_size=$3 #fdt_size в блоках unit_size
  let "fdt_size_mb=(fdt_size*unit_size)/mb"
  echo "fdt_size_mb" $fdt_size_mb
  sys_size=$4 #32768 #sys_size в блоках unit_size
  let "sys_size_mb=(sys_size*unit_size)/mb"
  echo "sys_size_mb" $fdt_size_mb

  storage_size=$5 #4000000 в блоках unit_size
  zeroimagename=$6

  echo "Generate MBR block size" $unit_size "rootfs size" $rootfs_size "fdt_size" $fdt_size "sys_size" $sys_size
  
  #let "sys_size=4+(fdt_size*2)+(rootfs_size*2)+(sys_size*2)"

  #echo "System size in block" $sys_size

  let "sys_size_b=(storage_size*unit_size)/mb"
  #' * '$unit_size
   echo "Image size" $sys_size_b "MB"

  parted $zeroimagename -s mktable msdos
  echo [parted $zeroimagename -s mktable msdos]

  

  let "start_sect=fdt_size+skip_sectors"
  let "start=(fdt_size_mb*mb)+PART_OFFSET"
  start_fit1=$PART_OFFSET
  #резерв 1024 для extended раздела
  let "start_fit1_ext=start_fit1-1024"
  let "end_fit1=(start)-unit_size"
  fit1_offset=$PART_OFFSET
  let "fit1_offset512=fit1_offset/512"
  
  parted $zeroimagename -s mkpart extended $start_fit1_ext"B" 100%
  echo [parted $zeroimagename -s mkpart extended $start_fit1_ext"B" 100%]
  #let "end=fdt_size_mb+2"
  #parted mbr mkpart p ext4 1 $end #create fact fdt
  #let "start=end"
  let "end_sect=start_sect+rootfs_size-1"
  let "end=start+((rootfs_size_mb)*mb)-(unit_size)"

  #parted $zeroimagename -s mkpart fact ext4 $skip_sectors"s" $start

  parted $zeroimagename -s mkpart logical ext4 $start"B" $end"B" #create fact rootfs
  echo [parted $zeroimagename -s mkpart logical ext4 $start"B" $end"B"]

  


   let "fit2_offset=end"
   
  #let "fit2_offset512_inc=fit2_offset512+1" 
  let "start_fit2=end+(unit_size*2)"

  let "fit2_offset512=start_fit2/512"
  echo FIT1 start $fit1_offset byte $fit1_offset512 sector_size $unit_size
  echo FIT2 start $start_fit2 byte $fit2_offset512 sector_size $unit_size
  printf "setenv fitfact_offset512 0x%08x\n" $fit1_offset512
  printf "setenv fituser_offset512 0x%08x\n" $fit2_offset512

  let "start=end+(fdt_size_mb*mb)+(unit_size*3)"
  let "end_fit2=start-(unit_size*2)"
 # let "end=start+fdt_size_mb"
 # parted mbr mkpart p ext4 $start $end #create user fdt
 # let "start=end"
  let "end=start+((rootfs_size_mb)*mb)-unit_size"
  parted $zeroimagename -s mkpart logical ext4 $start"B" $end"B" #create user rootfs
  echo [parted $zeroimagename -s mkpart logical ext4 $start"B" $end"B"]
  let "start=end+(unit_size*2)"
  let "end=start+(sys_size_mb*mb)-unit_size"
  parted $zeroimagename -s mkpart logical ext4 $start"B" $end"B" #create sys
  echo [parted $zeroimagename -s mkpart logical ext4 $start"B" $end"B"]
  let "start=end+(unit_size*2)"
  let "end=start+(sys_size_mb*mb)-unit_size"
  parted $zeroimagename -s mkpart logical ext4 $start"B" $end"B" #create sys_ex
  echo [parted $zeroimagename -s mkpart logical ext4 $start"B" $end"B"]
  let "start=end+(unit_size*2)"

  if [ -d "$IMAGE_CFG_FOLDER/efi/" ]; then
    efi_start=$start
    let "efi_end=efi_start+(32*mb)-1"
    let "start=efi_start+(32*mb)"
  fi

  parted $zeroimagename -s mkpart logical ext4 $start"B" 100% #create download and update
  echo [parted $zeroimagename -s mkpart logical ext4 $start"B" 100%]

 parted $zeroimagename -s mkpart logical ext4 $start_fit1"B" $end_fit1"B"
 echo [parted $zeroimagename -s mkpart logical ext4 $start_fit1"B" $end_fit1"B"]
 parted $zeroimagename -s mkpart logical ext4 $start_fit2"B" $end_fit2"B"
 echo [parted $zeroimagename -s mkpart logical ext4 $start_fit2"B" $end_fit2"B"]

 if [ -d "$IMAGE_CFG_FOLDER/efi/" ]; then
    echo Make EFI partition 
    parted $zeroimagename -s mkpart boot fat32 $efi_start"B" $efi_end"B"
    echo parted $zeroimagename -s set 12 boot on
    parted $zeroimagename -s set 12 boot on
 fi

  parted $zeroimagename print
  echo "Success create MBR"
}

function CreatePartitions_ffitroot_ufitroot_sys_sysex_sharedGPT {
  #$1 - sector size
  #$2 - rootfs max size in sectors
  #$3 - fdt max size in sectors
  #$4 - sys max size in sectors
  #$5 - storage max size in sectors
  #$6 - image name 

  mb=1048576

  if [ -z $PART_OFFSET ]; then 
    skip_sectors=8192
  else
    let "skip_sectors=PART_OFFSET/512"
  fi


  
  unit_size=$1
  rootfs_size=$2 #rootfs_size в блоках unit_size
  let "rootfs_size_mb=(rootfs_size*unit_size)/mb"
  echo "rootfs_size" $rootfs_size "rootfs_size_mb" $rootfs_size_mb
  fdt_size=$3 #fdt_size в блоках unit_size
  let "fdt_size_mb=(fdt_size*unit_size)/mb"
  echo "fdt_size_mb" $fdt_size_mb
  sys_size=$4 #32768 #sys_size в блоках unit_size
  let "sys_size_mb=(sys_size*unit_size)/mb"
  echo "sys_size_mb" $fdt_size_mb

  storage_size=$5 #4000000 в блоках unit_size
  zeroimagename=$6

  echo "Generate GPT block size" $unit_size "rootfs size" $rootfs_size "fdt_size" $fdt_size "sys_size" $sys_size
  
  #let "sys_size=4+(fdt_size*2)+(rootfs_size*2)+(sys_size*2)"

  #echo "System size in block" $sys_size

  let "sys_size_b=(storage_size*unit_size)/mb"
  #' * '$unit_size
   echo "Image size" $sys_size_b "MB"

  parted $zeroimagename -s mktable gpt
  echo parted $zeroimagename mktable gpt
  let "start_sect=fdt_size+skip_sectors"
  let "start=(fdt_size_mb*mb)+(skip_sectors*unit_size)"
  let "start_fit1=(skip_sectors*unit_size)"
  let "end_fit1=(start)-unit_size"
  let "fit1_offset=skip_sectors*unit_size"
  let "fit1_offset512=fit1_offset/512"
  
 
  #let "end=fdt_size_mb+2"
  #parted mbr mkpart p ext4 1 $end #create fact fdt
  #let "start=end"
  let "end_sect=start_sect+rootfs_size-1"
  let "end=start+((rootfs_size_mb)*mb)-unit_size"

  #parted $zeroimagename -s mkpart fact ext4 $skip_sectors"s" $start

  parted $zeroimagename -s mkpart fact ext4 $start"B" $end"B" #create fact rootfs
  echo parted $zeroimagename mkpart fact ext4 $start"B" $end"B"
   let "fit2_offset=end"
   
  #let "fit2_offset512_inc=fit2_offset512+1" 
  let "start_fit2=end+unit_size"

  let "fit2_offset512=start_fit2/512"
  echo FIT1 start $fit1_offset byte $fit1_offset512 sector_size $unit_size
  echo FIT2 start $start_fit2 byte $fit2_offset512 sector_size $unit_size
  printf "setenv fitfact_offset512 0x%08x\n" $fit1_offset512
  printf "setenv fituser_offset512 0x%08x\n" $fit2_offset512

  let "start=end+(fdt_size_mb*mb)+unit_size"
  let "end_fit2=start-unit_size"
 # let "end=start+fdt_size_mb"
 # parted mbr mkpart p ext4 $start $end #create user fdt
 # let "start=end"
  let "end=start+((rootfs_size_mb)*mb)-unit_size"
  parted $zeroimagename -s mkpart user ext4 $start"B" $end"B" #create user rootfs
  echo parted $zeroimagename mkpart user ext4 $start $end
  let "start=end+unit_size"
  let "end=start+(sys_size_mb*mb)-unit_size"
  parted $zeroimagename -s mkpart sys ext4 $start"B" $end"B" #create sys
  echo parted $zeroimagename mkpart sys ext4 $start $end
  let "start=end+unit_size"
  let "end=start+(sys_size_mb*mb)-unit_size"
  parted $zeroimagename -s mkpart sys_ex ext4 $start"B" $end"B" #create sys_ex
  echo parted $zeroimagename mkpart sys_ex ext4 $start $end
  let "start=end+unit_size"

  if [ -d "$IMAGE_CFG_FOLDER/efi/" ]; then
    efi_start=$start
    let "efi_end=efi_start+(32*mb)-1"
    let "start=efi_start+(32*mb)"
  fi

  parted $zeroimagename -s mkpart shared ext4 $start"B" 100% #create download and update
  echo parted $zeroimagename mkpart shared ext4 $start 100%

 parted $zeroimagename -s mkpart ffit ext4 $start_fit1"B" $end_fit1"B"
 parted $zeroimagename -s mkpart ufit ext4 $start_fit2"B" $end_fit2"B"

 echo IMAGE_CFG_FOLDER [$IMAGE_CFG_FOLDER] $IMAGE_CFG_FOLDER/efi/
 if [ -d "$IMAGE_CFG_FOLDER/efi/" ]; then
    echo Make EFI partition 
    parted $zeroimagename -s mkpart boot fat32 $efi_start"B" $efi_end"B"
    echo parted $zeroimagename -s set 8 boot on
    parted $zeroimagename -s set 8 boot on
 fi

  parted $zeroimagename print
  echo "Success create GPT"
}

function UpdateToZeroImage_ffitroot_ufitroot_sys_sysex_shared {

  #$1 - update file
  #$2 - zero image
  
  shared_drv=$PNUM_SHARED
  mnt=shared_mnt
  updfile=$1
  zeroimagename=$2
  device=/dev/loop0
  losetup -D

  echo losetup -P $device $zeroimagename
  losetup -P $device $zeroimagename
  mkdir $mnt
  mount $device"p"$shared_drv $mnt
  mkdir $mnt$DOWNLOAD_FOLDER
  mkdir $mnt$UPDATE_FOLDER
  cp $updfile $mnt$DOWNLOAD_FOLDER
  umount $mnt
  sync
  rm -r $mnt
  InsertBinary $device
  losetup -D
  echo Update File $updfile added to $DOWNLOAD_FOLDER zero image

}


function FillZeroImage_ffitroot_ufitroot_sys_sysex_shared
{
  #$1 - out image name
  #$2 - root dev or image file
  #$3 - fit dev or image file
  #$4 - passport

  zeroimagename=$1
  root_image=$2
  fit_image=$3
  passport=$4

  fzDevice=/dev/loop0

  echo FillZeroImage zeroimagename=$zeroimagename root_image=$root_image fit_image=$fit_image passport=$passport

  losetup -D
  rm $fzDevice"p"$PNUM_FACT
  rm $fzDevice"p"$PNUM_FFIT
  losetup -P $fzDevice $zeroimagename
   echo "losetup -P $fzDevice $zeroimagename"

    FillImage_ffitroot_ufitroot_sys_sysex_shared $root_image $fit_image $fzDevice"p" $passport
    InsertBinary $fzDevice
    losetup -D
    rm $fzDevice"p"$PNUM_FACT
    rm $fzDevice"p"$PNUM_FFIT
    #dd if=$zeroimagename of=test.get_fit bs=4M count=4 seek=1
    #echo dd if=$zeroimagename of=test.get_fit bs=16M count=1 seek=8192
    echo "losetup -D"
}

function FillImage_ffitroot_ufitroot_sys_sysex_shared
{
  #$1 - root dev or image file
  #$2 - fit dev or image file
  #$3 - device
  #$4 - passport

  root_image=$1
  fit_image=$2
  device=$3
  passport=$4

  #$ROOT_NAME
  sys_drv=$PNUM_SYS
  sys_ex_drv=$PNUM_SYSEX
  shared_drv=$PNUM_SHARED

  if [ -d "$IMAGE_CFG_FOLDER/efi/" ]; then
    echo RollOut EFI partition 
    efi_drv=$PNUM_EFI
    mkfs.vfat $device$efi_drv
    mkdir $CACHE_PATH/$IMAGE_FOLDER/boot
    echo $device$efi_drv $CACHE_PATH/$IMAGE_FOLDER/boot
    mount $device$efi_drv $CACHE_PATH/$IMAGE_FOLDER/boot
    echo rsync  -az  $IMAGE_CFG_FOLDER/efi/ $CACHE_PATH/$IMAGE_FOLDER/boot
    rsync  -az  $IMAGE_CFG_FOLDER/efi/ $CACHE_PATH/$IMAGE_FOLDER/boot
    cp $SPATH/$IMAGE_PATH/rootfs/epboot $CACHE_PATH/$IMAGE_FOLDER/boot
    echo umount $CACHE_PATH/$IMAGE_FOLDER/boot
    umount $CACHE_PATH/$IMAGE_FOLDER/boot
  fi

  echo "FillZeroImage"

  mkfs.ext4 $device$shared_drv
  mkfs.ext4 $device$sys_ex_drv
  mkfs.ext4 $device$sys_drv
  dd if=$root_image of=$device$PNUM_FACT
  echo dd if=$root_image of=$device$PNUM_FACT
  dd if=$fit_image of=$device$PNUM_FFIT
  echo dd if=$fit_image of=$device$PNUM_FFIT
  dd if=/dev/zero of=$device$PNUM_FFIT seek=$NATIVE_IMAGE_PASSPORT_OFFSET bs=$NATIVE_IMAGE_BLOCK_SIZE count=$NATIVE_IMAGE_FIT_SIZE conv=notrunc
  echo dd if=/dev/zero of=$device$PNUM_FFIT seek=$NATIVE_IMAGE_PASSPORT_OFFSET bs=$NATIVE_IMAGE_BLOCK_SIZE count=$NATIVE_IMAGE_FIT_SIZE conv=notrunc

  #cat /dev/zero | dd of=$ZEROIMAGE seek=$NATIVE_IMAGE_PASSPORT_OFFSET bs=$NATIVE_IMAGE_BLOCK_SIZE count=$NATIVE_IMAGE_FIT_SIZE conv=notrunc
  dd if=$passport of=$device$PNUM_FFIT seek=$NATIVE_IMAGE_PASSPORT_OFFSET bs=$NATIVE_IMAGE_BLOCK_SIZE conv=notrunc
  echo dd if=$passport of=$device$PNUM_FFIT seek=$NATIVE_IMAGE_PASSPORT_OFFSET bs=$NATIVE_IMAGE_BLOCK_SIZE conv=notrunc
  cat $passport
  echo Insert passport to $ZEROIMAGE 

}

function PassportPartitions_ffitroot_ufitroot_sys_sysex_shared
{
  PassportPartitions_result='"ffit_ro":"'$NECRON_FIT1_ROOT_DEVICE'","froot_ro":"'$NECRON_FACTORY_ROOT_DEVICE'","ufit_ro":"'$NECRON_FIT2_ROOT_DEVICE'","uroot_ro":"'$NECRON_USER_ROOT_DEVICE'","sys_rw":"'$NECRON_SYS_ROOT_DEVICE'","sys_ex_rw":"'$NECRON_SYSEX_ROOT_DEVICE'","ushared_rw":"'$NECRON_SHARE_ROOT_DEVICE'"'
}

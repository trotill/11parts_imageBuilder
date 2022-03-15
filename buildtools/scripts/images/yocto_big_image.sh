#EMMC_PATH
#ROOTFS_MAX_SIZE
#BASH READ PASSPORT dd if=/mnt/1_1908_16.imx6qd_forza_release_emmc.update of=/testss ibs=512 skip=30720 count=2048
#dd if=/mnt/1_1908_20.imx6qd_forza_release_emmc.update skip=2048 bs=8192 count=117965|head -c 966367744|md5sum
#unpack rootfs dd if=/www/pages/update/firmware.gzip skip=2048 ibs=8192|gunzip|dd of=/dev/mmcblk1p2 bs=8192
#unpack fit dd if=/www/pages/update/firmware.gzip of=/dev/mmcblk1p7 count=2048 bs=8192
#depend: e2fsprogs parted

NECRON_IMAGE_CONFIG_PATH=$SPATH/buildtools/conf/$IMAGE_FOLDER/cfg/necron_image.conf

source $SPATH/buildtools/conf/$IMAGE_FOLDER/cfg/obsoleteBash_callback.sh

NECRON_FACTORY_SCRIPT_PATH=$SPATH/buildtools/scripts/images/utils/yocto_big_image-factory.sh
NECRON_FACTORY_CFG_PATH=$SPATH/buildtools/conf/$IMAGE_FOLDER/cfg/factory.json
NECRON_SELECT_IMAGE="big"

if [ -z "$NECRON_FS_PART_TABLE" ]
then
	NECRON_FS_PART_TABLE="GPT"
fi
echo Select partition mode $NECRON_FS_PART_TABLE

if [ -f "$NECRON_IMAGE_CONFIG_PATH" ]
then
	echo "$NECRON_IMAGE_CONFIG_PATH found."

  source $NECRON_IMAGE_CONFIG_PATH
  source $SPATH"/buildtools/scripts/images/utils/necron_partitions_"$NECRON_IMAGE_TYPE".sh"
  NECRON_STARTUP=necron_startup_$NECRON_IMAGE_TYPE.sh
  NECRON_STARTUP_PATH=$SPATH/buildtools/scripts/images/utils/$NECRON_STARTUP

  function EditImages {
    IMAGEPARTS_PATH=$1
    echo -------------------------------------------------------------------------EDIT_IMAGES RUN

    EditImagesBefore ""
    source $SPATH/buildtools/scripts/private/configure.sh
    EditImagesBeforeGlobal ""
    ConfigureSyncReplaces ""

    rm -R $IMAGEPARTS_PATH/rootfs/etc/network
    rm $IMAGEPARTS_PATH/rootfs/etc/dnsmasq.conf
    rm $IMAGEPARTS_PATH/rootfs/etc/init.d/dnsmasq
    rm $IMAGEPARTS_PATH/noda_debug/sys/account.*
    install -d $IMAGEPARTS_PATH/rootfs/www/pages/download
    install -d $IMAGEPARTS_PATH/rootfs/www/pages/log
    install -d $IMAGEPARTS_PATH/rootfs/www/pages/necron
    install -d $IMAGEPARTS_PATH/rootfs/www/pages/sys
    install -d $IMAGEPARTS_PATH/rootfs/www/pages/sys_ex
    install -d $IMAGEPARTS_PATH/rootfs/www/pages/update
    #cp -aRd $IMAGEPARTS_PATH/rootfs/etc/necron/* $IMAGEPARTS_PATH/noda/sys/
    #cp -aRd $IMAGEPARTS_PATH/rootfs/etc/necron/* $IMAGEPARTS_PATH/noda/sys_ex/
    #chmod augo+x $IMAGEPARTS_PATH/noda/necron/Jnoda/app/base/udhcpc.conf
    #chown -R www-data.www-data $IMAGEPARTS_PATH/noda/

    #only for NFS
    install -d $SPATH/$IMAGE_PATH/rootfs
    #rm -R  $SPATH/$IMAGE_PATH/rootfs/*
    rsync  -az --delete $SPATH/tmp/imageparts/rootfs/ $SPATH/$IMAGE_PATH/rootfs
    #echo rsync  -az --delete $SPATH/tmp/imageparts/kernel/ $SPATH/$IMAGE_PATH/rootfs/boot
    rsync  -az --delete $SPATH/tmp/imageparts/kernel/ $SPATH/$IMAGE_PATH/rootfs/boot
    rsync  -az  $SPATH/tmp/imageparts/kernel-dtb/ $SPATH/$IMAGE_PATH/rootfs/boot
    rsync  -az  $SPATH/tmp/imageparts/u-boot/ $SPATH/$IMAGE_PATH/rootfs/boot
    rsync  -az  $SPATH/$IMAGE_PATH/rootfs/boot/6x_bootscript.ext $SPATH/$IMAGE_PATH/rootfs/6x_bootscript
    rsync  -az  $SPATH/$IMAGE_PATH/rootfs/boot/6x_bootscript.ext $SPATH/$IMAGE_PATH/rootfs/epboot

    if [ $NECRON_DEBUG -eq 1 ]
      then
          echo EditImages run with debug opts, install SSH and FTP
        ConfigureSSH ""
        ConfigureFTP ""
    fi
    ConfigureDistro ""
    EditImagesAfter ""
    EditImagesAfterGlobal ""
    echo -------------------------------------------------------------------------EDIT_IMAGES EXIT

  }


  function BuildPassportEMMC {
    #$1 - image

    image=$1
    fitfinger=$2
    rootfinger=$3
    fitsize=$4
    rootsize=$5
    # /dev/mmcblk0 or /dev/mmcblk1

    finger=$(md5sum $image|cut -d ' ' -f 1);

    image_name=$CONFIG_NAME
    version=$VERSION
    updtype=$UPDATE_TYPE
    cpuname=$CPU_NAME
    hwname=$HW_NAME

    PassportPartitions_result="\"undefined\":0"
    PassportPartitions_$NECRON_IMAGE_TYPE ""
    Undelete=""
    if test -f "$SPATH/tmp/imageparts/noda_settings/undelete.set"; then
        Undelete='"undelete":'$(cat $SPATH/tmp/imageparts/noda_settings/undelete.set | sed -e '/[\/\/]/d' | tr -d "\n" | tr -d " ")','
        #$(cat $SPATH/tmp/imageparts/noda_settings/undelete.set)','
    fi


    PASSPORT="{$Undelete\"finger_type\":\"md5\",\"finger\":\"$finger\",\"image\":\"$image_name\",\
    \"version\":\"$version\",\"updtype\":\"$updtype\",\"cpu\":\"$cpuname\",\"hw\":\"$hwname\",\
    \"fitfinger\":\"$fitfinger\",\"fitsize\":\"$fitsize\",\"rootsize\":\"$rootsize\",\"rootfinger\":\"$rootfinger\",\"rootcompression\":\"gzip\",\"stortype\":\"emmc\","$PassportPartitions_result"}";

    echo $PASSPORT>$PASSPORT_NAME
    echo "Passport ready "$PASSPORT
  }


  function PackFS_ext4 {

    rootfs_size_in_blocks=$1
    block_size=$2

    echo Pack fs ext4
    install -d $CACHE_PATH/mnt
    install -d $CACHE_PATH/$IMAGE_FOLDER

    let "img_size=rootfs_size_in_blocks*block_size"
    echo block_size $block_size count $rootfs_size_in_blocks Image size $img_size
    dd if=/dev/zero of=$ROOT_NAME bs=$block_size count=$rootfs_size_in_blocks status=progress
    echo $ROOT_NAME created
    #dd if=/dev/zero of=$ROOT_NAME bs=$block_size count=$rootfs_size_in_blocks
    sync
    mkfs.ext4 $ROOT_NAME $NECRON_MKFS_ROOT_OPTS
    sync
    mount -o loop $ROOT_NAME $CACHE_PATH/mnt
    sync
    rsync  -az $SPATH/$IMAGE_PATH/rootfs/ $CACHE_PATH/mnt
    sync
    ls $CACHE_PATH/mnt -l
    du -sh $CACHE_PATH/mnt
    df|grep $CACHE_PATH/mnt
    umount $CACHE_PATH/mnt
  }

  function PackFS_squash {
    echo Pack fs squash
    rm $ROOT_NAME
    mksquashfs $ROOTFS $ROOT_NAME
  }

  function PreBuildFactoryImage {

    rootfs_size_in_blocks=$1
    block_size=$2

    ROOTFS=$SPATH/$IMAGE_PATH/rootfs
    IMAGEPARTS=$SPATH/tmp/imageparts
    NECRON_PATH=$ROOTFS/usr/share/necron
    install -d $NECRON_PATH
    install -d $NECRON_PATH/node_modules
    rsync -az --delete $IMAGEPARTS/noda_build/necron/ $NECRON_PATH
    syncNodeModules ""


    install -d $SPATH/$IMAGE_PATH/rootfs/etc/necron/utils
    echo rsync $SPATH"/buildtools/scripts/images/utils/necron_partitions_"$NECRON_IMAGE_TYPE".sh"
    rsync  -az  $SPATH"/buildtools/scripts/images/utils/necron_partitions_"$NECRON_IMAGE_TYPE".sh" $SPATH/$IMAGE_PATH/rootfs/etc/necron/utils

    echo rsync  -az  $NECRON_IMAGE_CONFIG_PATH $SPATH/$IMAGE_PATH/rootfs/etc/necron/
    rsync  -az  $NECRON_IMAGE_CONFIG_PATH $SPATH/$IMAGE_PATH/rootfs/etc/necron/

    echo rsync  -az  $NECRON_STARTUP_PATH $SPATH/$IMAGE_PATH/rootfs/etc/necron/
    rsync  -az  $NECRON_STARTUP_PATH $SPATH/$IMAGE_PATH/rootfs/etc/necron/necron_startup.sh

    ln -s ../necron/necron_startup.sh $SPATH/$IMAGE_PATH/rootfs/etc/rc5.d/S90necron_startup.sh
    echo ln -s ../necron/necron_startup.sh $SPATH/$IMAGE_PATH/rootfs/etc/rc5.d/S90necron_startup.sh

    ln -s ../necron/necron_startup.sh $SPATH/$IMAGE_PATH/rootfs/etc/rc11p.start.d/S90necron_startup.sh
    echo ln -s ../necron/necron_startup.sh $SPATH/$IMAGE_PATH/rootfs/etc/rc11p.start.d/S90necron_startup.sh

    cp $NECRON_FACTORY_SCRIPT_PATH $SPATH/$IMAGE_PATH/rootfs/etc/factory.sh
    rsync -az $NECRON_FACTORY_CFG_PATH $SPATH/$IMAGE_PATH/rootfs/etc/

    #tar -zcvf necron.tar.gz /e100loc/project/imx6ull/project/necron/images/imx6ull_master_debug_sdonly/rootfs/etc/necron/

    case $NECRON_FS_ROOT_MOUNT_FS in
      ext4)
        PackFS_ext4 $rootfs_size_in_blocks $block_size
      ;;
      squashfs)
        PackFS_squash ""
      ;;
    esac

    #


    #root.squash
  }

  function BuildFactoryImage {
      echo "Script name " $SCRIPT_NAME


    #PASSPORT SIZE 1M 10485576
    PASSPORT="{}";

    rootfs_size_in_blocks=$1
    block_size=$2
    PreBuildFactoryImage $rootfs_size_in_blocks $block_size

    fitfinger=$(md5sum $FIT_NAME|cut -d ' ' -f 1);
    fitsize=$(stat -c%s $FIT_NAME);

    rootfinger=$(md5sum $ROOT_NAME|cut -d ' ' -f 1);
    rootsize=$(stat -c%s $ROOT_NAME);

    dd if=$FIT_NAME of=$UPDATE_NAME
    cat /dev/zero | dd of=$UPDATE_NAME seek=$NATIVE_IMAGE_PASSPORT_OFFSET bs=$NATIVE_IMAGE_BLOCK_SIZE count=$NATIVE_IMAGE_FIT_SIZE
    gzip $ROOT_NAME --keep
    dd if=$ROOT_NAME'.gz' of=$UPDATE_NAME seek=$NATIVE_IMAGE_ROOT_OFFSET bs=$NATIVE_IMAGE_BLOCK_SIZE

    BuildPassportEMMC $UPDATE_NAME $fitfinger $rootfinger $fitsize $rootsize

    echo $PASSPORT | dd of=$UPDATE_NAME seek=$NATIVE_IMAGE_PASSPORT_OFFSET bs=$NATIVE_IMAGE_BLOCK_SIZE conv=notrunc
    echo Image signed
    #DATE=$(date +"%m-%d-%y")
    #cp $ROOT_NAME $IMAGE_DESTINATION/$IMAGE_FOLDER$DATE".firmware.img"
  }




  #bs 512, max 2G, user and fact 512Mb, fit and sys 16Mb
  #GenZeroImage $sector_size 1048576 32768 32768 4194304
  #FillZeroImage ""

  function CreateFIT {
    FIT_NAME=$1
    echo CreateFIT:Check $IMAGE_CFG_FOLDER/fit/
    if [ -d "$SPATH/$IMAGE_CFG_FOLDER/fit/" ]; then
      cp $SPATH/buildtools/conf/$IMAGE_FOLDER/fit/fit.its fit.its
      rsync  -az  $SPATH/$BOOTSCRIPT".factory" $SPATH/$IMAGE_PATH/rootfs/boot/bootscript.scr.factory
      rsync  -az  $SPATH/$BOOTSCRIPT".user" $SPATH/$IMAGE_PATH/rootfs/boot/bootscript.scr.user
      echo "Run mkimage -T script -C none -n arm -f "$SPATH"/buildtools/conf/$IMAGE_FOLDER/fit/fit.its "$FIT_NAME
      mkimage -T script -C none -n arm -f fit.its $FIT_NAME
      rm fit.its
    else
      echo "Create FAKE FIT image 16Mb" $FIT_NAME
      dd if=/dev/zero of=$FIT_NAME bs=16M count=1
      let "bootscript_usr_seek=SIZE_1MB/2"
      mkimage -T script -C none -n $BOOTSCRIPT_CPU -d $SPATH/$BOOTSCRIPT".factory" $SPATH/$IMAGE_PATH/rootfs/boot/bootscript.scr.factory
      mkimage -T script -C none -n $BOOTSCRIPT_CPU -d $SPATH/$BOOTSCRIPT".user" $SPATH/$IMAGE_PATH/rootfs/boot/bootscript.scr.user

      dd if=boot/bootscript.scr.factory of=$FIT_NAME seek=0
      dd if=boot/bootscript.scr.user of=$FIT_NAME seek=1 bs=$bootscript_usr_seek
      ls "boot" -l
      if [ -f "boot/bzImage" ]; then
        dd if=boot/bzImage of=$FIT_NAME seek=1 bs=$SIZE_1MB
        echo "Add bzImage to FAKE FIT!!!"
      else
        if [ -f "boot/Image" ]; then
          dd if=boot/Image of=$FIT_NAME seek=1 bs=$SIZE_1MB
          echo "Add Image to FAKE FIT!!!"
        else
          if [ -f "boot/zImage" ]; then
            dd if=boot/Image of=$FIT_NAME seek=1 bs=$SIZE_1MB
            echo "Add zImage to FAKE FIT!!!"
          else
            echo "ERROR CREATE FAKE FIT, not found kernel images"
          fi
        fi
      fi
      echo "FAKE FIT ready" $FIT_NAME
      #dd if=$ROOT_NAME'.gz' of=$UPDATE_NAME seek=$NATIVE_IMAGE_ROOT_OFFSET bs=$NATIVE_IMAGE_BLOCK_SIZE
      #boot/bootscript.scr.factory"
    fi

  }

  function MakeImages {
    echo "Make firmware"
    source $SPATH/buildtools/scripts/private/configure.sh
    ReGenVersion ""

    CACHE_PATH=/var/necron/cache
    install -d $CACHE_PATH
    install -d $CACHE_PATH/mnt
    install -d $CACHE_PATH/$IMAGE_FOLDER

    ROOT_NAME=$CACHE_PATH/root.img
    PASSPORT_NAME=$CACHE_PATH/passport
    #FIRMWARE_NAME=$CONFIG_NAME'.emmc'
    UPDATE_NAME=$CACHE_PATH/firmware.img
    IMAGE_NAME=$CONFIG_NAME
    IMAGE_PATH=$1
    ZEROIMAGE=$CACHE_PATH/$VERSION'.'$IMAGE_NAME".img"
    FIT_NAME=$CACHE_PATH/image.itb
    PT=$PWD
    cd $SPATH/$IMAGE_PATH/rootfs/

    sector_size=$NECRON_UPDATER_SECTOR_SIZE
    #fat_size=1000M
    #fat_offset=2048

    #GenMBR 512 512Mb 16Mb 16Mb
    #GenMBR $sector_size 1048576 32768 32768

    echo "ITS file" $SPATH/buildtools/conf/$IMAGE_FOLDER/fit/fit.its
    echo "rootfs path "$SPATH/$IMAGE_PATH/rootfs/

    #ls -l

    CreateFIT $FIT_NAME


    #rm -R $SPATH/$IMAGE_PATH/rootfs/boot/
      cd $PT


    let "rootfs_partition_size_in_blocks=NECRON_UPDATER_ROOTFS_MAX_SIZE_IN_BYTES/sector_size"
    let "fit_partition_size_in_blocks=NECRON_UPDATER_FIT_MAX_SIZE_IN_BYTES/sector_size"
    let "sys_partition_size_in_blocks=NECRON_UPDATER_SYS_MAX_SIZE_IN_BYTES/sector_size"
    #let "storage_size_in_blocks=rootfs_partition_size_in_blocks*4"
    if [ -z $NECRON_UPDATER_STORAGE_MAX_SIZE_IN_BYTES ]
    then
      let "storage_size_in_blocks=rootfs_partition_size_in_blocks*4"
    else
      let "storage_size_in_blocks=NECRON_UPDATER_STORAGE_MAX_SIZE_IN_BYTES/sector_size"
    fi

    let "rootfs_size_in_blocks=rootfs_partition_size_in_blocks"
    #-(rootfs_partition_size_in_blocks/10)"

    BuildFactoryImage $rootfs_size_in_blocks $sector_size
    sync
    GenZeroImage_$NECRON_IMAGE_TYPE $sector_size $rootfs_partition_size_in_blocks $fit_partition_size_in_blocks $sys_partition_size_in_blocks $storage_size_in_blocks $ZEROIMAGE
    FillZeroImage_$NECRON_IMAGE_TYPE $ZEROIMAGE $ROOT_NAME $FIT_NAME $PASSPORT_NAME
    UpdateToZeroImage_$NECRON_IMAGE_TYPE $UPDATE_NAME $ZEROIMAGE

    gzip -f $ZEROIMAGE

    install -d $IMAGE_DESTINATION
    install -d $IMAGE_DESTINATION/bs
    BUILD_ID=$(cat $SPATH/$IMAGE_PATH/rootfs/etc/build_id.txt)

    echo Place $IMAGE_DESTINATION/$VERSION'['$BUILD_ID']'$BUILD_TSTAMP'.'$IMAGE_NAME".img.gz"
    cp $ZEROIMAGE.gz $IMAGE_DESTINATION/$VERSION'['$BUILD_ID']'$BUILD_TSTAMP'.'$IMAGE_NAME".img.gz"
    echo Place $IMAGE_DESTINATION/$VERSION'['$BUILD_ID']'$BUILD_TSTAMP'.'$IMAGE_NAME".update"
    cp $UPDATE_NAME $IMAGE_DESTINATION/$VERSION'['$BUILD_ID']'$BUILD_TSTAMP'.'$IMAGE_NAME".update"
    echo Place $IMAGE_DESTINATION/bs/$VERSION'['$BUILD_ID']'$IMAGE_NAME".epboot"
    cp $SPATH/$IMAGE_PATH/rootfs/epboot $IMAGE_DESTINATION/bs/$VERSION'['$BUILD_ID']'$IMAGE_NAME".epboot"
    echo Place $IMAGE_DESTINATION/bs/6x_bootscript
    cp $SPATH/$IMAGE_PATH/rootfs/epboot $IMAGE_DESTINATION/bs/6x_bootscript
    rm -Rd $CACHE_PATH/
    echo 'Success'
    exit 1;
  }
else
	echo "$NECRON_IMAGE_CONFIG_PATH not found. Please fill $NECRON_IMAGE_CONFIG_PATH"
fi
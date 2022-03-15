let {$,cd,unCd,echo,globToBash}=require('../utils');
let g=require('../global').getGlobal();
let im=require('../private/images');
let path=require('path');
let fs=require('fs');
let execSync=require('child_process').execSync;

function Init(){
    g.NECRON_IMAGE_CONFIG_PATH=`${g.SPATH}/buildtools/conf/${g.IMAGE_FOLDER}/cfg/necron_image.conf`;
    g.NECRON_FACTORY_SCRIPT_PATH=`${g.SPATH}/buildtools/scripts/images/utils/yocto_big_image-factory.sh`;
    g.NECRON_FACTORY_CFG_PATH=`${g.SPATH}/buildtools/conf/${g.IMAGE_FOLDER}/cfg/factory.json`;
    g.NECRON_SELECT_IMAGE="big";
    if (g.NECRON_FS_PART_TABLE===undefined){
        g.NECRON_FS_PART_TABLE="GPT";
    }
}
function EditImages (IMAGEPARTS_PATH){
    Init();
    echo(`-------------------------------------------------------------------------EDIT_IMAGES RUN`);
    g.EditImagesBefore();
   // source $SPATH/buildtools/scripts/private/configure.sh
    im.EditImagesBeforeGlobal(IMAGEPARTS_PATH);
    im.ConfigureSyncReplaces(IMAGEPARTS_PATH)
    $(`rm -R ${IMAGEPARTS_PATH}/rootfs/etc/network`);
    $(`rm ${IMAGEPARTS_PATH}/rootfs/etc/dnsmasq.conf`);
    $(`rm ${IMAGEPARTS_PATH}/rootfs/etc/init.d/dnsmasq`);
    $(`rm ${IMAGEPARTS_PATH}/noda_debug/sys/account.*`);
    $(`install -d ${IMAGEPARTS_PATH}/rootfs/www/pages/download`);
    $(`install -d ${IMAGEPARTS_PATH}/rootfs/www/pages/log`);
    $(`install -d ${IMAGEPARTS_PATH}/rootfs/www/pages/necron`);
    $(`install -d ${IMAGEPARTS_PATH}/rootfs/www/pages/sys`);
    $(`install -d ${IMAGEPARTS_PATH}/rootfs/www/pages/sys_ex`);
    $(`install -d ${IMAGEPARTS_PATH}/rootfs/www/pages/update`);
    $(`install -d ${g.SPATH}/${g.IMAGE_PATH}/rootfs`);
	$(`rsync  -az --delete ${g.SPATH}/tmp/imageparts/rootfs/ ${g.SPATH}/${g.IMAGE_PATH}/rootfs`);
	$(`rsync  -az --delete ${g.SPATH}/tmp/imageparts/kernel/ ${g.SPATH}/${g.IMAGE_PATH}/rootfs/boot`);
	$(`rsync  -az  ${g.SPATH}/tmp/imageparts/kernel-dtb/ ${g.SPATH}/${g.IMAGE_PATH}/rootfs/boot`);
	$(`rsync  -az  ${g.SPATH}/tmp/imageparts/u-boot/ ${g.SPATH}/${g.IMAGE_PATH}/rootfs/boot`);
	$(`rsync  -az  ${g.SPATH}/${g.IMAGE_PATH}/rootfs/boot/6x_bootscript.ext ${g.SPATH}/${g.IMAGE_PATH}/rootfs/6x_bootscript`);
	$(`rsync  -az  ${g.SPATH}/${g.IMAGE_PATH}/rootfs/boot/6x_bootscript.ext ${g.SPATH}/${g.IMAGE_PATH}/rootfs/epboot`)

	if (g.NECRON_DEBUG===1){
		    echo(`EditImages run with debug opts, install SSH and FTP`);
			im.ConfigureSSH();
			im.ConfigureFTP();
	}
	im.ConfigureDistro(IMAGEPARTS_PATH);
	g.EditImagesAfter();
	im.EditImagesAfterGlobal(IMAGEPARTS_PATH);
	echo(`-------------------------------------------------------------------------EDIT_IMAGES EXIT`);
}

function BuildPassportEMMC({image,fitfinger,rootfinger,fitsize,rootsize}) {

    let finger=execSync(`md5sum ${image}|cut -d ' ' -f 1`);

    let image_name=g.CONFIG_NAME;
    let version=g.VERSION;
    let updtype=g.UPDATE_TYPE;
    let cpuname=g.CPU_NAME;
    let hwname=g.HW_NAME;

    let PassportPartitions_result={"undefined":0};
    execSync(`${g.NECRON_IMAGE_CONFIG_PATH};
    ${g.SPATH}/buildtools/scripts/images/utils/necron_partitions_$NECRON_IMAGE_TYPE.sh;
    PassportPartitions_$NECRON_IMAGE_TYPE ""`
    )
   // PassportPartitions_$NECRON_IMAGE_TYPE ""
    let Undelete={};
    let undelPath=`${g.SPATH}/tmp/imageparts/noda_settings/undelete.set`;
    if (fs.existsSync(undelPath)){
        let undDataStr=fs.readFileSync(undelPath).toString();
        let undDataStrClean=undDataStr.replace(/[\n\r]/g,'');
        Undelete={"undelete":JSON.parse(undDataStrClean)};
   }

    let passport={
        Undelete,
        finger_type:"md5",
        finger:finger,
        image:image_name,
        version:version,
        updtype:updtype,
        cpu:cpuname,
        hw:hwname,
        fitfinger:fitfinger,
        fitsize:fitsize,
        rootsize:rootsize,
        rootfinger:rootfinger,
        rootcompression:'gzip',
        stortype:'emmc',
        PassportPartitions_result
    }
   fs.writeFileSync(g.PASSPORT_NAME,JSON.stringify(passport))
   // echo('PASSPORT>$PASSPORT_NAME
    echo("Passport ready ",passport);
}

function MakeImages(){
    Init();
    let expVar=globToBash(g);
    $(`install -d ${g.IMAGE_PATH}`);
    $(`${expVar}${g.SPATH}/buildtools/scripts/images/bigImage.sh`);
}
/*
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
*/
module.exports={
    EditImages,
    MakeImages
}


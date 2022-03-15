let {$,cd,unCd,echo}=require('../utils');
let g=require('../global').getGlobal();
let im=require('../private/images');
let path=require('path');
let fs=require('fs');
const execSync = require('child_process').execSync;

function Init(){

    g.NECRON_SELECT_IMAGE="ext4only";
}

function EditImages(IMAGEPARTS_PATH) {
	Init();
    echo('Run EditImages');

    g.EditImagesBefore();
    im.EditImagesBeforeGlobal(IMAGEPARTS_PATH);
    im.ConfigureSyncReplaces(IMAGEPARTS_PATH);
    
    $(`install -d ${IMAGEPARTS_PATH}/rootfs/www/pages`);
	$(`install -d ${g.SPATH}/${g.IMAGE_PATH}/rootfs`);
	$(`rsync -az --delete ${g.SPATH}/tmp/imageparts/rootfs/ ${g.SPATH}/${g.IMAGE_PATH}/rootfs`);
	$(`rsync -az --delete ${g.SPATH}/tmp/imageparts/kernel/ ${g.SPATH}/${g.IMAGE_PATH}/rootfs/boot`);
	$(`rsync -az ${g.SPATH}/tmp/imageparts/kernel-dtb/ ${g.SPATH}/${g.IMAGE_PATH}/rootfs/boot`);
	$(`rsync -az ${g.SPATH}/tmp/imageparts/u-boot/ ${g.SPATH}/${g.IMAGE_PATH}/rootfs/boot`);

	echo(`COPY ${g.SPATH}/buildtools/scripts/images/utils/S89watchdog_stub.sh ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/rc5.d/S89watchdog_stub.sh`);
	$(`cp -a ${g.SPATH}/buildtools/scripts/images/utils/S89watchdog_stub.sh ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/rc5.d/S89watchdog_stub.sh`);
	$(`cp -a ${g.SPATH}/buildtools/scripts/images/utils/S90necron.sh ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/rc5.d/S90necron.sh`);

	im.ConfigureSSH();
	im.ConfigureFTP();
	im.ConfigureDistro(IMAGEPARTS_PATH);

	$(`cp ${g.SPATH}/buildtools/scripts/images/utils/yocto_master_debug_sdonly-necron ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/necron`);
	$(`cp ${g.SPATH}/buildtools/scripts/images/utils/yocto_master_debug_sdonly-watchdog_stub ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/watchdog_stub`);

	g.EditImagesAfter();
	im.EditImagesAfterGlobal(IMAGEPARTS_PATH);
}

function RollOutImages(zeroimagename) {
	let device='/dev/loop0';
	$(`losetup -P ${device} ${zeroimagename}`);
	$(`mkfs.ext4 ${device}p1`);
	$(`mkfs.ext4 ${device}p2`);

	$(`mkdir ${g.CACHE_PATH}/${g.IMAGE_FOLDER}/rootfs`);
	$(`mkdir ${g.CACHE_PATH}/${g.IMAGE_FOLDER}/necron`);

	$(`mount ${device}p1 ${g.CACHE_PATH}/${g.IMAGE_FOLDER}/rootfs`);
	$(`mount ${device}p2 ${g.CACHE_PATH}/${g.IMAGE_FOLDER}/necron`);

	$(`rsync  -az ${g.SPATH}/${g.IMAGE_PATH}/rootfs/ ${g.CACHE_PATH}/${g.IMAGE_FOLDER}/rootfs`);

	$(`cp /${g.SPATH}/tmp/imageparts/u-boot/6x_bootscript ${g.CACHE_PATH}/${g.IMAGE_FOLDER}/rootfs/6x_bootscript`);
	$(`cp /${g.SPATH}/tmp/imageparts/u-boot/6x_bootscript ${g.CACHE_PATH}/${g.IMAGE_FOLDER}/rootfs/epboot`);

	im.syncNodeModules();
	$(`rsync  -az  ${g.SPATH}/tmp/imageparts/noda_build/ ${g.CACHE_PATH}/${g.IMAGE_FOLDER}/necron`);
	$(`umount ${g.CACHE_PATH}/${g.IMAGE_FOLDER}/rootfs`);
	$(`umount ${g.CACHE_PATH}/${g.IMAGE_FOLDER}/necron`);

	if (fs.existsSync(`${g.IMAGE_CFG_FOLDER}/efi/`)){
		echo(`RollOut EFI partition`);
		$(`mkfs.vfat ${device}p3`);
		$(`mkdir ${g.CACHE_PATH}/${g.IMAGE_FOLDER}/boot`);
		$(`mount ${device}p3 ${g.CACHE_PATH}/${g.IMAGE_FOLDER}/boot`);
		$(`rsync  -az  ${g.SPATH}/${g.IMAGE_CFG_FOLDER}/efi/ ${g.CACHE_PATH}/${g.IMAGE_FOLDER}/boot`);

		$(`umount ${g.CACHE_PATH}/${g.IMAGE_FOLDER}/boot`);
	}

	$(`sync`);

	g.InsertBinary(device);

	$(`losetup -D`);

}

function MakeImages (IMAGE_PATH){
	echo("Make ext4only Image");
	//let bid=fs.readFileSync(`${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/build_id.txt`).toString().replace(/[\n\r]/g, '');;

	let IMAGE_NAME=g.CONFIG_NAME;

	$(`install -d ${g.CACHE_PATH}/${g.IMAGE_FOLDER}`);

	let version=im.ReGenVersion();
	MakePartitions(g.CACHE_PATH+'/'+g.IMAGE_FOLDER+'/'+IMAGE_NAME+'.img');

	RollOutImages(`${g.CACHE_PATH}/${g.IMAGE_FOLDER}/${IMAGE_NAME}.img`);
	$(`gzip -f ${g.CACHE_PATH}/${g.IMAGE_FOLDER}/${IMAGE_NAME}.img`);
	let DATE=new Date();
	let BUILD_ID=fs.readFileSync(`${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/build_id.txt`).toString().replace(/[\n\r]/g, '');;
	//DATE=$(date +"%m-%d-%y")
	$(`install -d ${g.IMAGE_DESTINATION}`);
	$(`cp ${g.CACHE_PATH}/${g.IMAGE_FOLDER}/${IMAGE_NAME}.img.gz ${g.IMAGE_DESTINATION}/${version}[${BUILD_ID}]${IMAGE_NAME}.img.gz`);
	$(`rm -Rd ${g.CACHE_PATH}/`);
	echo('Success');
}

function MakePartitions(zeroimagename){


	let part2_size_mb=200;
	let part3_size_mb=32;
	let part1_offset_start_b=0;

	if (g.addSizePartMB1===undefined) {
		g.addSizePartMB1 = 0;
	}

	if (g.addSizePartMB2===undefined)
		g.addSizePartMB2=0;


	if (g.addSizePartMB3===undefined)
		g.addSizePartMB3=0;

	if (g.PART_OFFSET===undefined)
		part1_offset_start_b=1048576;
	else
		part1_offset_start_b=g.PART_OFFSET;


	let dirSize=im.CalcDirSize(`${g.SPATH}/${g.IMAGE_PATH}/rootfs/`)
	echo(`Total file size in rootfs ${dirSize}'B'`);


	let additions=(dirSize*30)/100;
	echo(`Calc additions ${additions}'MB'`);
	let part1_size_b=((Math.trunc((dirSize+additions)/1048576)+1)*1048576)+(g.addSizePartMB1*1048576);
	part2_size_mb+=g.addSizePartMB2;
	part3_size_mb+=g.addSizePartMB3;

	echo(`Rootfs partition size ${part1_size_b}' Bytes'`);
	let part1_offset_end_b=part1_offset_start_b+part1_size_b-1;

	let part2_offset_start_b=part1_offset_start_b+part1_size_b;
	let part2_offset_end_b=part2_offset_start_b+(1048576*part2_size_mb)-1;

	let part3_offset_start_b=part2_offset_start_b+(1048576*part2_size_mb);
	let part3_offset_end_b=part3_offset_start_b+(1048576*part3_size_mb)-1;

	let zeroimage_size=part3_offset_start_b+(1048576*(part3_size_mb+1));
	let zeroimage_size_mb=Math.trunc(zeroimage_size/1048576);

	$(`dd if=/dev/zero of=${zeroimagename} bs=1048576 count=${zeroimage_size_mb}`);

	let part1_size_mb=Math.trunc(part1_size_b/1048576);

	echo(`MakePartitions ImageName ${zeroimagename} part1_size ${part1_size_mb} part2_size ${part2_size_mb} part3_size ${part3_size_mb}`);
	echo(`Check ${g.IMAGE_CFG_FOLDER}/efi/`);


	if (fs.existsSync(`${g.IMAGE_CFG_FOLDER}/efi/`)) {
		echo(`parted ${zeroimagename} -s mktable gpt`);
		$(`parted ${zeroimagename} -s mktable gpt`);
	}
	else{
		echo(`parted ${zeroimagename} -s mktable msdos`);
		$(`parted ${zeroimagename} -s mktable msdos`);
	}

	//echo(`parted ${zeroimagename} -s mkpart primary ext4 $part1_offset_start_b"B" $part1_offset_end_b"B"`);
	$(`parted ${zeroimagename} -s mkpart primary ext4 ${part1_offset_start_b}"B" ${part1_offset_end_b}"B"`);

//	echo parted $zeroimagename -s mkpart primary ext4 $part2_offset_start_b"B" $part2_offset_end_b"B"
	$(`parted ${zeroimagename} -s mkpart primary ext4 ${part2_offset_start_b}"B" ${part2_offset_end_b}"B"`);

	if (fs.existsSync(`${g.IMAGE_CFG_FOLDER}/efi/`)){
		echo(`Make EFI partition`);
		$(`parted ${zeroimagename} -s mkpart boot fat32 ${part3_offset_start_b}"B" ${part3_offset_end_b}"B"`);
		$(`parted ${zeroimagename} -s set 3 boot on`);
	}
}
module.exports={
    EditImages:EditImages,
	MakeImages:MakeImages
}
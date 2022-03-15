let path = require('path');
let fs= require('fs');


let SPATH=path.join(__dirname,'..','..','..');

module.exports.calkPath=(glob)=>{
    let CONFIG_NAME=`${glob.CPU_NAME}_${glob.PROJECT_NAME}_${glob.PROJECT_DISTRO}_${glob.PROJECT_STOR}`;
    let PRIVATE_PATH= `${SPATH}/private`;
    let privateFile=path.join(PRIVATE_PATH,'path',CONFIG_NAME);
    let private=require(privateFile);
    console.log(`Read private ${privateFile}`,private);
    let imageFolder=`${glob.PROJECT_NAME}/${glob.CPU_NAME}/${glob.PROJECT_DISTRO}_${glob.PROJECT_STOR}`;
    let CACHE_PATH="/var/necron/cache";
    return {
        ...private,
        SPATH,
        CONFIG_NAME,
        PRIVATE_PATH,
        ROOT_NAME:`${CACHE_PATH}/root.img`,
        PASSPORT_NAME:`${CACHE_PATH}/passport`,
        CACHE_PATH:CACHE_PATH,
        BOOTLOADER : `${glob.CPU_NAME}/${glob.UBOOT_BOOTLOADER}`,
        IMAGE_COMMON : `${glob.PROJECT_NAME}/common`,
        IMAGE_CPU_COMMON : `${glob.PROJECT_NAME}/${glob.CPU_NAME}/common`,
        IMAGE_FOLDER : imageFolder,
        IMAGE_CFG_FOLDER : `buildtools/conf/${imageFolder}`,
        BOOTSCRIPT : `/buildtools/conf/${imageFolder}/uboot/bs.scr`,
        BOOTSCRIPT_CPU : `${glob.UBOOT_BOOTSCRIPT_CPU}`,
        IMAGE_PATH : `images/${imageFolder}`,
        IMAGE_DESTINATION: `${private.INSTALL_PATH}/${imageFolder}`,
        STRIP : `${private.CROSS_COMPILE}strip`,
        IMAGEPARTS : `${SPATH}/tmp/imageparts`,
        MAKE_PREFIX : (glob.MAKE_PREFIX===undefined)?'-j4':private.MAKE_PREFIX,
        ENGINE_REPO : (glob.ENGINE_REPO===undefined)?'git@github.com:trotill/11parts_CPP.git':glob.ENGINE_REPO,
    }
}


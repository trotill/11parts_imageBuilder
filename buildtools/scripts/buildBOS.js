let {$,cd,unCd,echo}=require('./utils');
let g=require('./global').getGlobal();
let path=require('path');

let DepMod=require('./private/depmod').DepMod;

module.exports.run=()=>{
    cd('tmp/cache/external');
    let KERNEL_DEMO_PATH=g.SPATH+"/kernel";
    echo('Sync u-boot');
    $(`install -d ${g.SPATH}/tmp/imageparts/u-boot/`);
    $(`install -d ${g.SPATH}/tmp/imageparts/kernel/`);
    $(`install -d ${g.SPATH}/tmp/imageparts/kernel-dtb/`);
    $(`rsync ${g.SPATH}/buildtools/bootloader/${g.BOOTLOADER} ${g.SPATH}/tmp/imageparts/u-boot/uboot`);
    $(`mkimage -T script -C none -n ${g.BOOTSCRIPT_CPU} -d ${g.SPATH}/${g.BOOTSCRIPT} ${g.SPATH}/tmp/imageparts/u-boot/6x_bootscript`);
    $(`mkimage -T script -C none -n ${g.BOOTSCRIPT_CPU} -d ${g.SPATH}/${g.BOOTSCRIPT}.ext ${g.SPATH}/tmp/imageparts/u-boot/6x_bootscript.ext`);
    echo(`sync ${g.KERNEL_PATH}/arch/arm/boot/[zImage,uImage,Image] to ${g.SPATH}/tmp/imageparts/kernel/`);
    $(`find ${g.KERNEL_PATH}/arch/ -iname Image.gz -o -iname zImage -o -iname uImage -o -iname bzImage|xargs cp -t ${g.SPATH}/tmp/imageparts/kernel/`);
    echo(`Sync ${g.KERNEL_PATH}/arch/${g.ARCH}/boot/dts to ${g.SPATH}/tmp/imageparts/kernel-dtb/`);
    $(`rm -R ${g.SPATH}/tmp/imageparts/kernel-dtb/*`);
    $(`find ${g.KERNEL_PATH}/arch/ -iname "*.dtb"|xargs cp -t ${g.SPATH}/tmp/imageparts/kernel-dtb/`);
    echo(`install -d ${g.SPATH}/${g.IMAGE_PATH}/rootfs`);
    $(`install -d ${g.SPATH}/${g.IMAGE_PATH}/rootfs`);

    echo(`KERNEL_DEMO_PATH ${g.KERNEL_DEMO_PATH} KERNEL_PATH ${g.KERNEL_PATH}`);
    echo(`MODULES_IN_ROOTFS ${g.MODULES_IN_ROOTFS}`);

    if (KERNEL_DEMO_PATH === g.KERNEL_PATH){
        echo("Skip Kernel lib, demo mode");
    }
    else{
        if(g.MODULES_IN_ROOTFS===1){
            echo("Skip Kernel lib, skip rebuild modules");
        }
        else{
            echo("Install Kernel lib");
            $(`rm -Rd ${g.SPATH}/tmp/imageparts/rootfs/lib/modules/*`);
            echo(`g.COMPILER_ROOT ${g.COMPILER_ROOT}`);
            if (!g.COMPILER_ROOT){
                $(`${globToBash(g)}make -C ${g.KERNEL_PATH} INSTALL_MOD_STRIP=1 modules_install INSTALL_MOD_PATH=${g.SPATH}/tmp/imageparts/rootfs/ ${g.MAKE_PREFIX}`);
                DepMod(`${g.SPATH}/tmp/imageparts/rootfs/`);
            }
            else{
                require('./ncModules.js');
                //$(`/bin/bash ${g.SPATH}/buildtools/scripts/dockerfiles/modulesinstall.sh ${g.SPATH}/tmp/imageparts/rootfs/`);
            }
        }
    }
}
let {$,cd,unCd,echo}=require('./utils');
let g=require('./global').getGlobal();
let path=require('path');
let fs=require('fs');

function relink(nameArr){
    nameArr.forEach((name)=>{
        $(`unlink ${g.SPATH}/tmp/imageparts/noda_build/necron/Cnoda/${name}`);
        $(`ln -s ${g.CNODA_NAME} ${g.SPATH}/tmp/imageparts/noda_build/necron/Cnoda/${name}`)
    })

}

module.exports.run=()=>{
    if (g.CNODA_REPO===undefined){
        echo('CNODA_REPO unset, skip BuildCnoda');
    }
    else{
        if (g.COMPILER_ROOT===undefined){
            $(`/bin/bash ${g.SDK_CROSS_SCRIPT};
           echo "Select SDK_CROSS_SCRIPT (Yocto SDK based)";
           cd ${g.SPATH}/tmp/cache/external/${g.CNODA_REPO_NAME}/srvIoT/build;
           rm CMakeCache.txt;
           rm -r CMakeFiles/;
           cmake "Unix Makefiles" ../;
           echo "Build Cnoda";
           make ${g.MAKE_PREFIX}`);
        }
        else{
            echo("Select SDK_CROSS_BUILD_SCRIPT (ArchLinux, Ubuntu)");
            cd(`${g.SPATH}/tmp/cache/external/${g.CNODA_REPO_NAME}/srvIoT`);
            $(`export COMPILER_ROOT=${g.COMPILER_ROOT};
                    export COMPILER_ROOT_BIN=${g.COMPILER_ROOT_BIN};
                    export ORIGINAL_ROOTFS_PATH=${g.ORIGINAL_ROOTFS_PATH};
                    export DOCKER_IMAGE_NAME=${g.DOCKER_IMAGE_NAME};
            /bin/bash dockbuild.sh remake`);
            cd(`${g.SPATH}/tmp/cache/external/${g.CNODA_REPO_NAME}/srvIoT/build`);
        }


        $(`install -d ${g.SPATH}/tmp/imageparts/noda_build/necron/Cnoda`);
        $(`rsync ${g.CNODA_NAME} ${g.SPATH}/tmp/imageparts/noda_build/necron/Cnoda`);
        $(`cp -aRd 'libcnoda.so' 'libcnoda.so.1' ${g.SPATH}/tmp/imageparts/rootfs/usr/lib`);

        $(`cp ${g.SPATH}/buildtools/conf/${g.IMAGE_COMMON}/replacements/Cnoda/* ${g.SPATH}/tmp/imageparts/noda_build/necron/Cnoda`);
        $(`cp ${g.SPATH}/buildtools/conf/${g.IMAGE_CPU_COMMON}/replacements/Cnoda/* ${g.SPATH}/tmp/imageparts/noda_build/necron/Cnoda`);
        $(`cp ${g.SPATH}/buildtools/conf/${g.IMAGE_FOLDER}/replacements/Cnoda/* ${g.SPATH}/tmp/imageparts/noda_build/necron/Cnoda`);

        relink(['evwdt','evnode','evcnoda','usb_reset','imcheck','gset','sset','snmpagnt','setclean','gprivate','factory','safe_logger']);
        $(`cp watchdog_stub ${g.SPATH}/tmp/imageparts/noda_build/necron/Cnoda/watchdog_stub`);
        $(`cp ssdpd ${g.SPATH}/tmp/imageparts/noda_build/necron/Cnoda/ssdpd`);
        $(`cp svc ${g.SPATH}/tmp/imageparts/noda_build/necron/Cnoda/svc`);
        $(`cp necron ${g.SPATH}/tmp/imageparts/noda_build/necron/Cnoda/necron`);
        if (g.EXTEND_SW_PATH===undefined){
            echo(`Skip build extend SW EXTEND_SW_PATH=["${g.EXTEND_SW_PATH}"]`);
        }
        else{
            echo(`Build extend SW EXTEND_SW_PATH=["${g.EXTEND_SW_PATH}"]`);
            $(`${g.EXTEND_BUILD_SCRIPT} ${g.SPATH}/tmp/imageparts/noda_build/necron/Cnoda/`);
        }
    }
    unCd();
}
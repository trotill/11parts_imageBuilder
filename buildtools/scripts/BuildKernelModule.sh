#!bin/sh

function BuildKernMod {

    source $SDK_CROSS_SCRIPT
    buildpath=$1
    #modname=$2
    instpath=$2
    define=$3

    SPT=$PWD
    MODULE_PATH=$SPATH/tmp/cache/external/external/device/$EXTERNAL_VERSION/$buildpath

    echo cd $SPATH/tmp/cache/external/external/device/$EXTERNAL_VERSION/$buildpath
     cd $MODULE_PATH
  

    echo KERNEL_PATH $KERNEL_PATH
    echo MODULE_PATH $MODULE_PATH
    echo make -C $KERNEL_PATH M=$MODULE_PATH AQROOT=$MODULE_PATH $MAKE_PREFIX 
    install -d $INSTALL_PATH

    make -C $KERNEL_PATH $define M=$MODULE_PATH AQROOT=$MODULE_PATH $MAKE_PREFIX 
    #$STRIP --strip-debug $MODULE_PATH/$modname.ko

    echo make -C $KERNEL_PATH $define M=$MODULE_PATH AQROOT=$MODULE_PATH modules_install INSTALL_MOD_PATH=$instpath
    make -C $KERNEL_PATH M=$MODULE_PATH AQROOT=$MODULE_PATH modules_install INSTALL_MOD_PATH=$instpath
    echo Install modules to $instpath
    
    cd $SPT
}

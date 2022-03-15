#!bin/sh

function BuildInput {
    inputdev=$1
    MODULE_PATH=$PWD/$inputdev

    echo KERNEL_PATH $KERNEL_PATH
    echo MODULE_PATH $MODULE_PATH
   
    echo make -C $KERNEL_PATH M=$MODULE_PATH AQROOT=$MODULE_PATH $MAKE_PREFIX 
    make -C $KERNEL_PATH M=$MODULE_PATH AQROOT=$MODULE_PATH $MAKE_PREFIX 
    $STRIP --strip-debug $MODULE_PATH/$inputdev.ko

    echo make -C $KERNEL_PATH M=$MODULE_PATH AQROOT=$MODULE_PATH modules_install INSTALL_MOD_PATH=$SPATH/tmp/imageparts/rootfs/
    make -C $KERNEL_PATH M=$MODULE_PATH AQROOT=$MODULE_PATH modules_install INSTALL_MOD_PATH=$SPATH/tmp/imageparts/rootfs/
    echo Install modules to $SPATH/tmp/imageparts/rootfs/

    echo Ready $MODULE_PATH/$inputdev.ko
}

source $SDK_CROSS_SCRIPT

SPT=$PWD

file=$1
echo Source dir $PWD
#cd $SPATH/tmp/cache/external
#echo Source dir $PWD

#echo cd $SPATH/tmp/cache/external


echo cd $SPATH/tmp/cache/external/external/device/$EXTERNAL_VERSION/input
     cd $SPATH/tmp/cache/external/external/device/$EXTERNAL_VERSION/input

#for file in `ls`  
#do
     echo "Build inputdev $file"
     BuildInput $file
     #read line
#done

cd $SPT
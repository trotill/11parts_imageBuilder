#!bin/sh

DEV=/dev/sdd

FIT=/e100loc/project/qoriq/lsdk/flexbuild/build/images/bootpartition_arm64_lts_4.9/flex_linux_arm64.itb
#/e100loc/project/qoriq/lsdk/flexbuild/build/firmware/qoriq-mc-binary/ls1088a/mc_10.4.0_ls1088a_20171101.itb
#/yocto/qoriq/build_ls1088ardb/tmp/work/ls1088ardb-fsl-linux/management-complex/10.3.4-r0/image/boot/mc_10.4.0_ls1088a_20171101.itb
FIT_OFFSET=32768

echo Write flex fit 
dd if=$FIT of=$DEV bs=512 seek=$FIT_OFFSET
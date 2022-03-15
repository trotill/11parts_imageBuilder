#!bin/sh

DEV=/dev/sdd

FW=/e100loc/project/qoriq/lsdk/flexbuild/build/images/firmware_ls1088ardb_uboot_sdboot.img
#/e100loc/project/qoriq/lsdk/flexbuild/build/firmware/qoriq-mc-binary/ls1088a/mc_10.4.0_ls1088a_20171101.itb
#/yocto/qoriq/build_ls1088ardb/tmp/work/ls1088ardb-fsl-linux/management-complex/10.3.4-r0/image/boot/mc_10.4.0_ls1088a_20171101.itb
FW_OFFSET=8

echo Write fw 
dd if=$FW of=$DEV bs=512 seek=$FW_OFFSET
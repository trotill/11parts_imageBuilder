#!bin/sh

DEV=/dev/sdd

PPA=/e100loc/project/qoriq/lsdk/flexbuild/build/firmware/ppa/soc-ls1088/ppa.itb
#/e100loc/project/qoriq/lsdk/flexbuild/build/firmware/qoriq-mc-binary/ls1088a/mc_10.4.0_ls1088a_20171101.itb
#/yocto/qoriq/build_ls1088ardb/tmp/work/ls1088ardb-fsl-linux/management-complex/10.3.4-r0/image/boot/mc_10.4.0_ls1088a_20171101.itb
PPA_OFFSET=8192

echo Write ppa 
dd if=$PPA of=$DEV bs=512 seek=$PPA_OFFSET
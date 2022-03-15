#!bin/sh

DPAA2_MC=/yocto/qoriq/build_ls1088ardb/tmp/work/ls1088ardb-fsl-linux/management-complex/10.3.4-r0/image/boot/mc_10.4.0_ls1088a_20171101.itb
#/e100loc/project/qoriq/lsdk/flexbuild/build/firmware/qoriq-mc-binary/ls1088a/mc_10.4.0_ls1088a_20171101.itb
#/yocto/qoriq/build_ls1088ardb/tmp/work/ls1088ardb-fsl-linux/management-complex/10.3.4-r0/image/boot/mc_10.4.0_ls1088a_20171101.itb
DPAA2_MC_OFFSET=20480

DPAA2_DPL=/e100loc/project/qoriq/my_build/mc-utils/config/ls1088a/RDB/custom/dpl-eth-sip.0x1D_0x0D.dtb
#/e100loc/project/qoriq/lsdk/flexbuild/build/firmware/mc-utils/config/ls1088a/RDB/dpl-eth.0x1D_0x0D.dtb
#/yocto/qoriq/build_ls1088ardb/tmp/work/aarch64-fsl-linux/mc-utils/git-r0/image/boot/mc-utils/dpl-eth.0x1D_0x0D.dtb
DPAA2_DPL_OFFSET=26624

DPAA2_DPC=/e100loc/project/qoriq/my_build/mc-utils/config/ls1088a/RDB/custom/dpc-bman-4M.0x1D-0x0D.dtb
#/e100loc/project/qoriq/lsdk/flexbuild/build/firmware/mc-utils/config/ls1088a/RDB/custom/dpc-bman-4M.0x1D-0x0D.dtb
#/yocto/qoriq/build_ls1088ardb/tmp/work/aarch64-fsl-linux/mc-utils/git-r0/image/boot/mc-utils/dpc.0x1D-0x0D.dtb
DPAA2_DPC_OFFSET=28672

echo Write dpaa2 mc
dd if=$DPAA2_MC of=$DEV bs=512 seek=$DPAA2_MC_OFFSET

echo Write dpaa2 dpl
dd if=$DPAA2_DPL of=$DEV bs=512 seek=$DPAA2_DPL_OFFSET

echo Write dpaa2 dpc
dd if=$DPAA2_DPC of=$DEV bs=512 seek=$DPAA2_DPC_OFFSET
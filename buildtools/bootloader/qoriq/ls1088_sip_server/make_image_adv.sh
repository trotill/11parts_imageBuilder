#!bin/sh

DEV=/dev/sdd

RCW_PBI=/e100loc/project/qoriq/lsdk/flexbuild/build/firmware/rcw/ls1088ardb/FCQQQQQQQQ_PPP_H_0x1d_0x0d/PBL_SD_1600_700_2100_0x1d_0x0d.bin
#RCW_PBI=rcw/ls1088ardb/NNNNNNNNNN_N_N_N_N/rcw_1600_qspi_giv.bin 
#RCW_PBI=rcw/ls1088ardb/FCQQQQQQQQ_PPP_H_0x1d_0x0d/rcw_1600_sd_giw.bin
RCW_PBI_OFFSET=8
#UBOOT=/e100loc/project/qoriq/lsdk/flexbuild/build/firmware/u-boot/ls1088ardb/uboot_ls1088ardb_sdcard_qspi.bin
#UBOOT=/e100loc/project/qoriq/my_build/u-booot_201709/u-boot-with-spl.bin
UBOOT=/e100loc/project/qoriq/my_build/u-booot_201707/u-boot-with-spl.bin
#/e100loc/project/qoriq/my_build/u-booot_201707/u-boot-with-spl.bin
UBOOT_OFFSET=2048

PPA=/yocto/qoriq/build_ls1088ardb/tmp/work/ls1088ardb-fsl-linux/ppa/git-r0/image/boot/ppa.itb
#/e100loc/project/qoriq/lsdk/flexbuild/build/firmware/ppa/soc-ls1088/ppa.itb
#/yocto/qoriq/build_ls1088ardb/tmp/work/ls1088ardb-fsl-linux/ppa/git-r0/image/boot/ppa.itb
PPA_OFFSET=8192

DPAA2_MC=/yocto/qoriq/build_ls1088ardb/tmp/work/ls1088ardb-fsl-linux/management-complex/10.3.4-r0/image/boot/mc_10.4.0_ls1088a_20171101.itb
#/e100loc/project/qoriq/lsdk/flexbuild/build/firmware/qoriq-mc-binary/ls1088a/mc_10.4.0_ls1088a_20171101.itb
#/yocto/qoriq/build_ls1088ardb/tmp/work/ls1088ardb-fsl-linux/management-complex/10.3.4-r0/image/boot/mc_10.4.0_ls1088a_20171101.itb
DPAA2_MC_OFFSET=20480

DPAA2_DPL=/e100loc/project/qoriq/my_build/mc-utils/config/ls1088a/RDB/custom/dpl-eth-sip.0x1D_0x0D.dtb
#/yocto/qoriq/build_ls1088ardb/tmp/work/aarch64-fsl-linux/mc-utils/git-r0/image/boot/mc-utils/dpl-eth.0x1D_0x0D.dtb
#/e100loc/project/qoriq/lsdk/flexbuild/build/firmware/mc-utils/config/ls1088a/RDB/dpl-eth.0x1D_0x0D.dtb
#/yocto/qoriq/build_ls1088ardb/tmp/work/aarch64-fsl-linux/mc-utils/git-r0/image/boot/mc-utils/dpl-eth.0x1D_0x0D.dtb
DPAA2_DPL_OFFSET=26624

DPAA2_DPC=/e100loc/project/qoriq/my_build/mc-utils/config/ls1088a/RDB/custom/dpc-bman-4M.0x1D-0x0D.dtb
#/yocto/qoriq/build_ls1088ardb/tmp/work/aarch64-fsl-linux/mc-utils/git-r0/image/boot/mc-utils/custom/dpc-bman-4M.0x1D-0x0D.dtb
#/e100loc/project/qoriq/lsdk/flexbuild/build/firmware/mc-utils/config/ls1088a/RDB/custom/dpc-bman-4M.0x1D-0x0D.dtb
#/yocto/qoriq/build_ls1088ardb/tmp/work/aarch64-fsl-linux/mc-utils/git-r0/image/boot/mc-utils/dpc.0x1D-0x0D.dtb
DPAA2_DPC_OFFSET=28672

DTS=/yocto/qoriq/build_ls1088ardb/tmp/work/ls1088ardb-fsl-linux/linux-qoriq/4.9-r0/image/boot/fsl-ls1088a-rdb.dtb
#/e100loc/project/imx6ull/project/necron/images/master/ls1088/debug_nfs/rootfs/boot/fsl-ls1088a-rdb.dtb
#/yocto/qoriq/build_ls1088ardb/tmp/work/ls1088ardb-fsl-linux/linux-qoriq/4.9-r0/image/boot/fsl-ls1088a-rdb.dtb
DTS_OFFSET=30720

KERNEL=/yocto/qoriq/build_ls1088ardb/tmp/deploy/images/ls1088ardb/itbImage-fsl-image-networking-ls1088ardb.bin
#/e100loc/project/imx6ull/project/necron/images/master/ls1088/debug_nfs/rootfs/boot/Image
#/yocto/qoriq/build_ls1088ardb/tmp/deploy/images/ls1088ardb/itbImage-fsl-image-networking-ls1088ardb.bin
#/yocto/qoriq/build_ls1088ardb/tmp/work/ls1088ardb-fsl-linux/linux-qoriq/4.9-r0/image/boot/Image
KERNEL_OFFSET=32768

echo Erase all shadow
dd if=/dev/zero of=$DEV bs=512 seek=$RCW_PBI_OFFSET count=30720
#32760

echo Write rcw pbi
dd if=$RCW_PBI of=$DEV bs=512 seek=$RCW_PBI_OFFSET

echo Write uboot
dd if=$UBOOT of=$DEV bs=512 seek=$UBOOT_OFFSET

echo Write ppa
dd if=$PPA of=$DEV bs=512 seek=$PPA_OFFSET

echo Write dpaa2 mc
dd if=$DPAA2_MC of=$DEV bs=512 seek=$DPAA2_MC_OFFSET

echo Write dpaa2 dpl
dd if=$DPAA2_DPL of=$DEV bs=512 seek=$DPAA2_DPL_OFFSET

echo Write dpaa2 dpc
dd if=$DPAA2_DPC of=$DEV bs=512 seek=$DPAA2_DPC_OFFSET

echo Write kernel dts
dd if=$DTS of=$DEV bs=512 seek=$DTS_OFFSET

echo Write kernel+ramdisk fit image
dd if=$KERNEL of=$DEV bs=512 seek=$KERNEL_OFFSET

echo Ready!!!
#!bin/sh

DEV=/dev/sdd

RCW_PBI=/e100loc/project/qoriq/lsdk/flexbuild/build/firmware/rcw/ls1088ardb/FCQQQQQQQQ_PPP_H_0x1d_0x0d/PBL_SD_1600_700_2100_0x1d_0x0d.bin
#RCW_PBI=rcw/ls1088ardb/NNNNNNNNNN_N_N_N_N/rcw_1600_qspi_giv.bin 
#RCW_PBI=rcw/ls1088ardb/FCQQQQQQQQ_PPP_H_0x1d_0x0d/rcw_1600_sd_giw.bin
#UBOOT=/e100loc/project/qoriq/lsdk/flexbuild/build/firmware/u-boot/ls1088ardb/uboot_ls1088ardb_sdcard_qspi.bin
#UBOOT=/e100loc/project/qoriq/lsdk/flexbuild/build/firmware/u-boot/ls1088ardb/uboot_ls1088ardb_sdcard_qspi.bin
#UBOOT=/e100loc/project/qoriq/my_build/u-booot_201709/u-boot-with-spl.bin
UBOOT=/e100loc/project/qoriq/my_build/u-booot_201707/u-boot-with-spl.bin
UBOOT_OFFSET=2048

echo Write uboot
dd if=$UBOOT of=$DEV bs=512 seek=$UBOOT_OFFSET

echo Ready!!!
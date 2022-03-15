#!bin/sh

function BuildWiFiRtl {
    wifi=$1
    MODULE_PATH=$PWD/$wifi/kernel-module
    SW_PATH=$wifi/sw
	INSTALL_PATH=$SPATH/tmp/imageparts/noda/necron/devices/wifi/rtl$wifi

    echo KERNEL_PATH $KERNEL_PATH
    echo MODULE_PATH $MODULE_PATH
    
    install -d $INSTALL_PATH

    export USER_EXTRA_CFLAGS=$WIFI_USER_EXTRA_CFLAGS
    export TopDIR=$MODULE_PATH
    echo export USER_EXTRA_CFLAGS=$WIFI_USER_EXTRA_CFLAGS
    echo make -C $KERNEL_PATH M=$MODULE_PATH AQROOT=$MODULE_PATH $MAKE_PREFIX
    make -C $KERNEL_PATH M=$MODULE_PATH AQROOT=$MODULE_PATH $MAKE_PREFIX 
    $STRIP --strip-debug $MODULE_PATH/$wifi.ko

    echo Copy $MODULE_PATH/$wifi.ko to $INSTALL_PATH/rtl$wifi.ko
    install $MODULE_PATH/$wifi.ko $INSTALL_PATH/rtl$wifi.ko

    make -C $SW_PATH/hostapd

    make -C $SW_PATH/wpa_supplicant

    install $SW_PATH/hostapd/hostapd $INSTALL_PATH/hostapd
    $STRIP --strip-debug $INSTALL_PATH/hostapd

    install $SW_PATH/hostapd/hostapd_cli $INSTALL_PATH/hostapd_cli
    $STRIP --strip-debug $INSTALL_PATH/hostapd_cli

    install $SW_PATH/wpa_supplicant/wpa_supplicant $INSTALL_PATH/wpa_supplicant
    install $SW_PATH/wpa_supplicant/wpa_passphrase $INSTALL_PATH/wpa_passphrase
    install $SW_PATH/wpa_supplicant/wpa_cli $INSTALL_PATH/wpa_cli

    $STRIP --strip-debug $INSTALL_PATH/wpa_supplicant
    $STRIP --strip-debug $INSTALL_PATH/wpa_passphrase
    $STRIP --strip-debug $INSTALL_PATH/wpa_cli

    echo Install path $INSTALL_PATH
    chmod augo+x $INSTALL_PATH/wpa_supplicant
    chmod augo+x $INSTALL_PATH/wpa_passphrase
    chmod augo+x $INSTALL_PATH/hostapd_cli
    chmod augo+x $INSTALL_PATH/wpa_cli
    chmod augo+x $INSTALL_PATH/hostapd
    ls $INSTALL_PATH -l
}

source $SDK_CROSS_SCRIPT


SPT=$PWD

echo cd $SPATH/tmp/cache/external/external/device/$EXTERNAL_VERSION/wifi
     cd $SPATH/tmp/cache/external/external/device/$EXTERNAL_VERSION/wifi

for file in `ls`  
do
     echo "Build WiFi $file"
     BuildWiFiRtl $file
     #read line
done

cd $SPT
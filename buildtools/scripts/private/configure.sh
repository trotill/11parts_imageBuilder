#!bin/sh
 
CONFIG_NAME=$CPU_NAME"_"$PROJECT_NAME"_"$PROJECT_DISTRO"_"$PROJECT_STOR
PRIVATE_PATH=$SPATH/private
BOOTLOADER=$CPU_NAME'/'$UBOOT_BOOTLOADER
IMAGE_COMMON=$PROJECT_NAME'/common'
IMAGE_CPU_COMMON=$PROJECT_NAME'/'$CPU_NAME'/common'
IMAGE_FOLDER=$PROJECT_NAME'/'$CPU_NAME'/'$PROJECT_DISTRO"_"$PROJECT_STOR
IMAGE_CFG_FOLDER='buildtools/conf/'$IMAGE_FOLDER
BOOTSCRIPT='/buildtools/conf/'$IMAGE_FOLDER'/uboot/bs.scr'
BOOTSCRIPT_CPU=$UBOOT_BOOTSCRIPT_CPU 
IMAGE_PATH=images/$IMAGE_FOLDER
IMAGE_DESTINATION=$INSTALL_PATH'/'$IMAGE_FOLDER
STRIP=$CROSS_COMPILE"strip"
IMAGEPARTS=$SPATH/tmp/imageparts
MAKE_PREFIX="-j4"
if [ -z $ENGINE_REPO ]; then 
	ENGINE_REPO='git@github.com:trotill/11parts_CPP.git'
fi
EXIT_STATUS=0


function resetPrivEnv {
	unset KERN_COMPILER_ROOT
	unset KERN_COMPILER_ROOT_BIN
	unset DOCKER_IMAGE_NAME
	unset INSTALL_PATH
	unset NODE_MODULES_ROOT
	unset COMPILE_JS
	unset MODULES_IN_ROOTFS
	unset NECRON_DEBUG
	unset KERNEL_PATH
	unset ORIGINAL_ROOTFS_PATH
	unset KERN_ARCH
}

echo "run "$SPATH/private/path/$CONFIG_NAME
if [ -f $SPATH/private/path/$CONFIG_NAME  ] 
then
	echo "Found private" $SPATH/private/path/$CONFIG_NAME 
	resetPrivEnv ""
	source $SPATH/private/path/$CONFIG_NAME
	if [ "$KERNEL_PATH" = "<Linux kernel path>" ]; then
		echo "Incorrect variable KERNEL_PATH in private " $KERNEL_PATH ", exit"
		exit 0
	fi
else 
	echo "Not found private" $SPATH/private/path/$CONFIG_NAME ", exit"
	#exit 0
fi

 

echo "ORIGINAL_ROOTFS_PATH "$ORIGINAL_ROOTFS_PATH

function RSYNCD {
	ARGS=$1;
	SRC=$2;
	DEST=$3;

	if [[ -d $SRC ]]; then
				echo "Rsync dir "$SRC" to "$DEST
				rsync $ARGS $SRC $DEST
	elif [[ -f $SRC ]]; then
				echo "Rsync file "$SRC" to "$DEST
				rsync $ARGS $SRC $DEST
	else
		echo "Skip rsync "$SRC" to "$DEST
	fi
}

function syncNodeModules {
	if [ -z $NECRON_PATH ];
	then
	  	NECRON_PATH=$IMAGEPARTS/noda_build
	fi
	
	if [ -z $NODE_MODULES_ROOT ];
  	then
  		echo PreBuildFactoryImage Use default NODE_MODULES_ROOT [rsync -az --delete $IMAGEPARTS/noda_modules/node_modules/ $NECRON_PATH/node_modules]
  		rsync -az --delete $IMAGEPARTS/noda_modules/node_modules/ $NECRON_PATH/node_modules
  	else
  		echo PreBuildFactoryImage Use NODE_MODULES_ROOT $NODE_MODULES_ROOT
  		echo rm -r $NECRON_PATH/node_modules
  		rm -r $NECRON_PATH/node_modules
  		echo ln -s $NODE_MODULES_ROOT $NECRON_PATH/node_modules
  		ln -s $NODE_MODULES_ROOT $NECRON_PATH/node_modules
  	fi
 }

function ConfigureSyncReplaces {
	chown -R root.root $IMAGEPARTS_PATH/rootfs/

	#echo Sync $SPATH/buildtools/conf/$IMAGE_COMMON/replacements/rootfs/ $IMAGEPARTS_PATH/rootfs
	RSYNCD "-az" $SPATH/buildtools/conf/$IMAGE_COMMON/replacements/rootfs/ $IMAGEPARTS_PATH/rootfs
	#echo Sync $SPATH/buildtools/conf/$IMAGE_COMMON/replacements/$PROJECT_STOR/ $IMAGEPARTS_PATH/rootfs
	RSYNCD "-az" $SPATH/buildtools/conf/$IMAGE_COMMON/replacements/$PROJECT_STOR/ $IMAGEPARTS_PATH/rootfs

	#echo Sync $SPATH/buildtools/conf/$IMAGE_CPU_COMMON/replacements/rootfs/ $IMAGEPARTS_PATH/rootfs
	RSYNCD "-az" $SPATH/buildtools/conf/$IMAGE_CPU_COMMON/replacements/rootfs/ $IMAGEPARTS_PATH/rootfs
	#echo Sync $SPATH/buildtools/conf/$IMAGE_CPU_COMMON/replacements/$PROJECT_STOR/ $IMAGEPARTS_PATH/rootfs
	RSYNCD "-az" $SPATH/buildtools/conf/$IMAGE_CPU_COMMON/replacements/$PROJECT_STOR/ $IMAGEPARTS_PATH/rootfs

	#echo Sync $SPATH/buildtools/conf/$IMAGE_FOLDER/replacements/rootfs/ $IMAGEPARTS_PATH/rootfs
	RSYNCD "-az" $SPATH/buildtools/conf/$IMAGE_FOLDER/replacements/rootfs/ $IMAGEPARTS_PATH/rootfs
	#echo Sync $SPATH/buildtools/conf/$IMAGE_FOLDER/replacements/$PROJECT_STOR/ $IMAGEPARTS_PATH/rootfs
	RSYNCD "-az" $SPATH/buildtools/conf/$IMAGE_FOLDER/replacements/$PROJECT_STOR/ $IMAGEPARTS_PATH/rootfs
}

function ConfigureSSH {
	root_user="/home/root"
	if [ -d "$SPATH/$IMAGE_PATH/rootfs/root" ]; then
		root_user="/root"
	fi
	install -d $SPATH/$IMAGE_PATH'/rootfs'$root_user'/.ssh/'
	rsync  -az  $PRIVATE_PATH/ssh/authorized_keys $SPATH/$IMAGE_PATH'/rootfs'$root_user'/.ssh/authorized_keys'
	rsync  -az  $PRIVATE_PATH/ssh/sshd_config $SPATH/$IMAGE_PATH/rootfs/etc/ssh/sshd_config
	rsync  -az  $PRIVATE_PATH/ssh/sshd_config_readonly $SPATH/$IMAGE_PATH/rootfs/etc/ssh/sshd_config_readonly
	chmod 700 $SPATH/$IMAGE_PATH'/rootfs'$root_user'/.ssh'
	chmod 600 $SPATH/$IMAGE_PATH'/rootfs'$root_user'/.ssh/authorized_keys'
	chown -R root.root $SPATH/$IMAGE_PATH/rootfs/etc/ssh/
	chown -R root.root $SPATH/$IMAGE_PATH'/rootfs'$root_user'/.ssh'
	chmod 600 $SPATH/$IMAGE_PATH/rootfs/etc/ssh/*
	chmod 600 $SPATH/$IMAGE_PATH'/rootfs'$root_user'/.ssh/*'
}

function ConfigureConsole {
	rsync  -az  $PRIVATE_PATH/console/* $SPATH/$IMAGE_PATH/rootfs/etc/
}

function ConfigureFTP {
	rsync  -az  $PRIVATE_PATH/ftp/ $SPATH/$IMAGE_PATH/rootfs/etc/
}

function ConfigureJS {
	source $SPATH/buildtools/scripts/grunt/build_js.sh
}

function ConfigureUdev {
	echo ConfigureUdev
	#if [ -f "$SPATH/$IMAGE_PATH/rootfs/lib/udev/srviot_events.sh" ]; then
	#	echo "found $SPATH/$IMAGE_PATH/rootfs/lib/udev/srviot_events.sh"
	#else
		echo cp -r $SPATH/buildtools/scripts/udev/lib/* $SPATH/$IMAGE_PATH/rootfs/lib/
		cp -r $SPATH/buildtools/scripts/udev/lib/* $SPATH/$IMAGE_PATH/rootfs/lib/
  	#fi	
}

function ConfigureSystemd {
	echo ConfigureSystemd
	if [ -d "$SPATH/$IMAGE_PATH/rootfs/etc/systemd" ]; then
		echo RollOut SYSTEMD scripts
		cp -r $SPATH/buildtools/scripts/systemd/etc/systemd/* $SPATH/$IMAGE_PATH/rootfs/etc/systemd/
		cp -r $SPATH/buildtools/scripts/systemd/etc/rc11pe.start.d $SPATH/$IMAGE_PATH/rootfs/etc/
		cp -r $SPATH/buildtools/scripts/systemd/etc/rc11pe.stop.d $SPATH/$IMAGE_PATH/rootfs/etc/
		cp -r $SPATH/buildtools/scripts/systemd/etc/rc11p.start.d $SPATH/$IMAGE_PATH/rootfs/etc/
		cp -r $SPATH/buildtools/scripts/systemd/etc/rc11p.stop.d $SPATH/$IMAGE_PATH/rootfs/etc/
		cp -r $SPATH/buildtools/scripts/systemd/usr/* $SPATH/$IMAGE_PATH/rootfs/usr/

		if [ "big" -eq "$NECRON_SELECT_IMAGE" ];
  		then
  			echo Image $NECRON_SELECT_IMAGE use overlayfs
  			cp -r $SPATH/buildtools/scripts/systemd/overlay/* $SPATH/$IMAGE_PATH/rootfs/etc/rc11pe.start.d
		fi

		if [ -d "$SPATH/$IMAGE_PATH/rootfs/etc/init.d/functions" ]; then
			echo "found $SPATH/$IMAGE_PATH/rootfs/etc/init.d/functions"
		else
			install -d $SPATH/$IMAGE_PATH/rootfs/etc/init.d/
			echo cp $SPATH/buildtools/scripts/systemd/etc/init.d/functions $SPATH/$IMAGE_PATH/rootfs/etc/init.d/functions
			cp $SPATH/buildtools/scripts/systemd/etc/init.d/functions $SPATH/$IMAGE_PATH/rootfs/etc/init.d/functions
		fi

		if [ -d "$SPATH/$IMAGE_PATH/rootfs/etc/init.d/rc" ]; then
			echo "found $SPATH/$IMAGE_PATH/rootfs/etc/init.d/rc"
		else
			install -d $SPATH/$IMAGE_PATH/rootfs/etc/init.d/
			echo cp $SPATH/buildtools/scripts/systemd/etc/init.d/rc $SPATH/$IMAGE_PATH/rootfs/etc/init.d/rc
			cp $SPATH/buildtools/scripts/systemd/etc/init.d/rc $SPATH/$IMAGE_PATH/rootfs/etc/init.d/rc
		fi

		if [ -d "$SPATH/$IMAGE_PATH/rootfs/etc/init.d/slogger.sh" ]; then
			echo "found $SPATH/$IMAGE_PATH/rootfs/etc/init.d/slogger.sh"
		else
			install -d $SPATH/$IMAGE_PATH/rootfs/etc/init.d/
			echo cp $SPATH/buildtools/scripts/systemd/etc/init.d/slogger.sh $SPATH/$IMAGE_PATH/rootfs/etc/init.d/slogger.sh
			cp $SPATH/buildtools/scripts/systemd/etc/init.d/slogger.sh $SPATH/$IMAGE_PATH/rootfs/etc/init.d/slogger.sh
		fi
		cp $SPATH/buildtools/scripts/systemd/etc/init.d/overlay $SPATH/$IMAGE_PATH/rootfs/etc/init.d/overlay
	fi
	echo RollOut SYSTEMD end
}

VERSION=""
BUILD_TSTAMP=""
function ReGenVersion {
	VDATE=$(date +"%y%m_%d")
	BUILD_TSTAMP=$(date +%s)
	VERSION=$VERSION_MAJOR"_"$VDATE
	echo "Regen version "$VERSION
}

BUILD_ID=""
function ReGenBuildId {
	BUILD_ID=$(shuf -i 10000-999000 -n 1)
	echo "BuildId "$BUILD_ID
	echo $BUILD_ID>$SPATH/$IMAGE_PATH/rootfs/etc/build_id.txt
}


function ConfigureDistro {
	
	ReGenVersion ""
	ReGenBuildId ""

	JSON='{"t":[1,1],"d":{"cpu":"'$CPU_NAME'","hw":"'$HW_NAME'","version_hw":"'$VERSION_HW'","version_major":"'$VERSION_MAJOR'","swvers":"'$SW_NAME' v'$VERSION'","swbuild":"'$BUILD_ID'","hwvers":"'$DEVICE_NAME' v'$VERSION_HW'","swdate":"'$(date +"20%y.%m.%d")'"'$DEVSTRINGJSON'}}'

	install -d $SPATH/$IMAGE_PATH/rootfs/etc/necron
	echo $JSON
	echo $JSON > $SPATH/$IMAGE_PATH/rootfs/etc/necron/settings.distro.set
	echo "Saved settings.distro.set"
	cp $SPATH/$IMAGE_PATH/rootfs/etc/necron/settings.distro.set $SPATH/tmp/imageparts/noda_settings/

	JSON='{"t":[1,1],"d":{"sn":"00000000"}}'
	echo $JSON > $SPATH/$IMAGE_PATH/rootfs/etc/necron/settings.serialn.set
	echo "Saved settings.serialn.set"
	cp $SPATH/$IMAGE_PATH/rootfs/etc/necron/settings.serialn.set $SPATH/tmp/imageparts/noda_settings/

	install -d $IMAGEPARTS_PATH/noda/sys
	install -d $IMAGEPARTS_PATH/noda/sys_ex
	
	rsync  -az --delete $SPATH/tmp/imageparts/noda_settings/ $SPATH/$IMAGE_PATH/rootfs/etc/necron
	rsync  -az --delete $SPATH/$IMAGE_PATH/rootfs/etc/necron/ $IMAGEPARTS_PATH/noda/sys/
	rsync  -az --delete $SPATH/$IMAGE_PATH/rootfs/etc/necron/ $IMAGEPARTS_PATH/noda/sys_ex/
}

function EditImagesBeforeGlobal {
   rm $SPATH/$IMAGE_PATH/rootfs/etc/ipsec.conf
   rm $SPATH/$IMAGE_PATH/rootfs/etc/ipsec.secrets
   rm $SPATH/$IMAGE_PATH/rootfs/etc/strongswan.conf
   rm $SPATH/$IMAGE_PATH/rootfs/usr/share/snmp/agent.conf
   	rm -R $IMAGEPARTS_PATH/rootfs/etc/network
	rm $IMAGEPARTS_PATH/rootfs/etc/dnsmasq.conf
	rm $IMAGEPARTS_PATH/rootfs/etc/init.d/dnsmasq
	rm $IMAGEPARTS_PATH/noda_debug/sys/account.*
}

function EditImagesAfterGlobal {
   rm $SPATH/$IMAGE_PATH/rootfs/etc/init.d/ntpd
   rm $SPATH/$IMAGE_PATH/rootfs/etc/init.d/avahi-daemon
   rm $SPATH/$IMAGE_PATH/rootfs/etc/ntp.conf
   rm $IMAGEPARTS_PATH/noda/sys/settings.serialn.set
   rm $IMAGEPARTS_PATH/noda/sys_ex/settings.serialn.set
   rm $SPATH/$IMAGE_PATH/rootfs/etc/xl2tpd/xl2tpd.conf
   rm $SPATH/$IMAGE_PATH/rootfs/etc/init.d/xl2tpd
   rm $SPATH/$IMAGE_PATH/rootfs/etc/init.d/openvpn
   rm $SPATH/$IMAGE_PATH/rootfs/etc/init.d/snmpd
   rm $SPATH/$IMAGE_PATH/rootfs/etc/init.d/ppp
   rm $SPATH/$IMAGE_PATH/rootfs/etc/init.d/sms3
   chmod augo+xwr $IMAGEPARTS_PATH/noda/necron/Jnoda/app/base/udhcpc.conf
   chmod augo+xwr $IMAGEPARTS_PATH/noda/necron/Jnoda/app/base/udhcpc_debug.conf
   chmod 600 $SPATH/$IMAGE_PATH/rootfs/etc/ssh/ssh_host_rsa_key
   chmod 600 $SPATH/$IMAGE_PATH/rootfs/etc/ssh/ssh_host_dsa_key
   chmod 600 $SPATH/$IMAGE_PATH/rootfs/etc/ssh/ssh_host_ecdsa_key
   ConfigureSystemd ""
   ConfigureUdev ""
   

}

function CalcDirSize {
	cdir=$1
	echo Calc dirsize $cdir
	SIZE=$(du -sb $cdir|cut -f1) 
	BLOCK_SIZE=512
	let "SIZE_IN_BLOCKS=(SIZE/BLOCK_SIZE)+1"
	let "SIZE=BLOCK_SIZE*SIZE_IN_BLOCKS"
	
}

function DepMod {
	ROOT_DIR=$1
	LIBDIR=$1'/lib/modules'
	kv=$(ls $LIBDIR)
	IFS=' ' read -ra ARR <<< "$kv"
	for vers in "${ARR[@]}"; do
		echo "depmod for kernel ["$vers"]"
		echo depmod -b $ROOT_DIR $vers
		depmod -b $ROOT_DIR $vers
   		
	done	
}
let {$,cd,unCd,echo}=require('../utils');
let g=require('../global').getGlobal();
let path=require('path');
let fs=require('fs');
const execSync = require('child_process').execSync;

function EditImagesBeforeGlobal(IMAGEPARTS_PATH) {
    $(`rm ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/ipsec.conf`);
    $(`rm ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/ipsec.secrets`);
    $(`rm ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/strongswan.conf`);
    $(`rm ${g.SPATH}/${g.IMAGE_PATH}/rootfs/usr/share/snmp/agent.conf`);
    $(`rm -R ${IMAGEPARTS_PATH}/rootfs/etc/network`);
    $(`rm ${IMAGEPARTS_PATH}/rootfs/etc/dnsmasq.conf`);
    $(`rm ${IMAGEPARTS_PATH}/rootfs/etc/init.d/dnsmasq`);
    $(`rm ${IMAGEPARTS_PATH}/noda_debug/sys/account.*`);
}

function EditImagesAfterGlobal(IMAGEPARTS_PATH) {
    $(`rm ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/ntpd`);
    $(`rm ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/avahi-daemon`);
    $(`rm ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/ntp.conf`);
    $(`rm ${IMAGEPARTS_PATH}/noda/sys/settings.serialn.set`);
    $(`rm ${IMAGEPARTS_PATH}/noda/sys_ex/settings.serialn.set`);
    $(`rm ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/xl2tpd/xl2tpd.conf`);
    $(`rm ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/xl2tpd`);
    $(`rm ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/openvpn`);
    $(`rm ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/snmpd`)
    $(`rm ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/ppp`)
    $(`rm ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/sms3`)
    $(`chmod augo+xwr ${IMAGEPARTS_PATH}/noda/necron/Jnoda/app/base/udhcpc.conf`)
    $(`chmod augo+xwr ${IMAGEPARTS_PATH}/noda/necron/Jnoda/app/base/udhcpc_debug.conf`)
    $(`chmod 600 ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/ssh/ssh_host_rsa_key`)
    $(`chmod 600 ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/ssh/ssh_host_dsa_key`)
    $(`chmod 600 ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/ssh/ssh_host_ecdsa_key`)
    ConfigureSystemd();
    ConfigureUdev()


}

function ConfigureSyncReplaces(IMAGEPARTS_PATH) {
    $(`chown -R root.root ${IMAGEPARTS_PATH}/rootfs/`);
    $(`rsync -az ${g.SPATH}/buildtools/conf/${g.IMAGE_COMMON}/replacements/rootfs/ ${IMAGEPARTS_PATH}/rootfs`);
    $(`rsync -az ${g.SPATH}/buildtools/conf/${g.IMAGE_COMMON}/replacements/${g.PROJECT_STOR}/ ${IMAGEPARTS_PATH}/rootfs`);
    $(`rsync -az ${g.SPATH}/buildtools/conf/${g.IMAGE_CPU_COMMON}/replacements/rootfs/ ${IMAGEPARTS_PATH}/rootfs`);
    $(`rsync -az ${g.SPATH}/buildtools/conf/${g.IMAGE_CPU_COMMON}/replacements/${g.PROJECT_STOR}/ ${IMAGEPARTS_PATH}/rootfs`);
   
    $(`rsync -az ${g.SPATH}/buildtools/conf/${g.IMAGE_FOLDER}/replacements/rootfs/ ${IMAGEPARTS_PATH}/rootfs`);
    $(`rsync -az ${g.SPATH}/buildtools/conf/${g.IMAGE_FOLDER}/replacements/${g.PROJECT_STOR}/ ${IMAGEPARTS_PATH}/rootfs`);
}

function ConfigureSSH() {
    let root_user="/home/root"
    if (fs.existsSync(`${g.SPATH}/${g.IMAGE_PATH}/rootfs/root`)) {
        root_user = "/root";
    }
    $(`install -d ${g.SPATH}/${g.IMAGE_PATH}/rootfs${root_user}/.ssh/`);
    $(`rsync  -az  ${g.PRIVATE_PATH}/ssh/authorized_keys ${g.SPATH}/${g.IMAGE_PATH}/rootfs${root_user}/.ssh/authorized_keys`);
    $(`rsync  -az  ${g.PRIVATE_PATH}/ssh/sshd_config ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/ssh/sshd_config`);
    $(`rsync  -az  ${g.PRIVATE_PATH}/ssh/sshd_config_readonly ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/ssh/sshd_config_readonly`);
    $(`chmod 700 ${g.SPATH}/${g.IMAGE_PATH}/rootfs${root_user}/.ssh`);
    $(`chmod 600 ${g.SPATH}/${g.IMAGE_PATH}/rootfs${root_user}/.ssh/authorized_keys`);
    $(`chown -R root.root ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/ssh/`);
    $(`chown -R root.root ${g.SPATH}/${g.IMAGE_PATH}/rootfs${root_user}/.ssh`);
    $(`chmod 600 ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/ssh/*`);
    $(`chmod 600 ${g.SPATH}/${g.IMAGE_PATH}/rootfs${root_user}/.ssh/*`);
}

function ConfigureConsole() {
	$(`rsync  -az  ${g.PRIVATE_PATH}/console/* ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/`);
}

function ConfigureFTP() {
	$(`rsync  -az  ${g.PRIVATE_PATH}/ftp/ ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/`);
}

function ConfigureUdev() {
	echo("ConfigureUdev");
	$(`cp -r ${g.SPATH}/buildtools/scripts/udev/lib/* ${g.SPATH}/${g.IMAGE_PATH}/rootfs/lib/`);
}

function ConfigureSystemd() {
	echo("ConfigureSystemd");
	if (fs.existsSync(`${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/systemd`)) {
		echo("RollOut SYSTEMD scripts");
		$(`cp -r ${g.SPATH}/buildtools/scripts/systemd/etc/systemd/* ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/systemd/`);
        //$(`cp -r ${g.SPATH}/buildtools/scripts/systemd/etc/rc11pe.start.d ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/`);
        //$(`cp -r ${g.SPATH}/buildtools/scripts/systemd/etc/rc11pe.stop.d ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/`);
        $(`cp -r ${g.SPATH}/buildtools/scripts/systemd/etc/rc11p.start.d ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/`);
        $(`cp -r ${g.SPATH}/buildtools/scripts/systemd/etc/rc11p.stop.d ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/`);
        $(`cp -r ${g.SPATH}/buildtools/scripts/systemd/usr/* ${g.SPATH}/${g.IMAGE_PATH}/rootfs/usr/`);
        

		if (g.NECRON_SELECT_IMAGE==="big"){
  			echo(`Image ${g.NECRON_SELECT_IMAGE} use overlayfs`);
  			$(`cp -r ${g.SPATH}/buildtools/scripts/systemd/overlay/* ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/rc11pe.start.d`);
		}

		if (fs.existsSync(`${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/functions`)){
			echo(`found ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/functions`);
		}
		else{
			$(`install -d ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/`);
			$(`cp ${g.SPATH}/buildtools/scripts/systemd/etc/init.d/functions ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/functions`);
		}

        if (fs.existsSync(`${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/rc`)){
            echo(`found ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/rc`);
        }
        else{
            $(`install -d ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/`);
            $(`cp ${g.SPATH}/buildtools/scripts/systemd/etc/init.d/rc ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/rc`);
        }

        if (fs.existsSync(`${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/slogger.sh`)){
            echo(`found ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/slogger.sh`);
        }
        else{
            $(`install -d ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/`);
            $(`cp ${g.SPATH}/buildtools/scripts/systemd/etc/init.d/slogger.sh ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/slogger.sh`);
        }
        
        $(`cp ${g.SPATH}/buildtools/scripts/systemd/etc/init.d/overlay ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/init.d/overlay`);
		
	}
	echo("RollOut SYSTEMD end");
}

function ReGenVersion() {
   // VDATE=$(date +"%y%m_%d")
   // BUILD_TSTAMP=$(date +%s)
    let date=Math.floor(Date.now() / 1000);
    g.VERSION=g.VERSION_MAJOR+"_"+date;
    echo(`"Regen version ${g.VERSION}`);
    return g.VERSION;
   // echo "Regen version "$VERSION
}

function ReGenBuildId() {
   // BUILD_ID=$(shuf -i 10000-999000 -n 1)
    let buildId=Math.floor(100000 + Math.random() * 900000);
    echo(`BuildId ${buildId}`);
    $(`echo ${buildId}>${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/build_id.txt`);
    return buildId;
}

function ConfigureDistro(IMAGEPARTS_PATH) {
    ReGenVersion();
    let buildId=ReGenBuildId();
    let JSON=`{"t":[1,1],"d":{"cpu":"${g.CPU_NAME}","hw":"${g.HW_NAME}","version_hw":"${g.VERSION_HW}","version_major":"${g.VERSION_MAJOR}","swvers":"${g.SW_NAME} v${g.VERSION}","swbuild":"${buildId}","hwvers":"${g.DEVICE_NAME} v${g.VERSION_HW}","swdate":"${new Date()}"${g.DEVSTRINGJSON}}}`;

    $(`install -d ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/necron`);
    echo(JSON);
    fs.writeFileSync(`${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/necron/settings.distro.set`,JSON);
    echo("Saved settings.distro.set");

    $(`cp ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/necron/settings.distro.set ${g.SPATH}/tmp/imageparts/noda_settings/`);

    let serialn='{"t":[1,1],"d":{"sn":"00000000"}}';
    fs.writeFileSync(`${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/necron/settings.serialn.set`,serialn);

    echo("Saved settings.serialn.set");

    $(`cp ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/necron/settings.serialn.set ${g.SPATH}/tmp/imageparts/noda_settings/`);

    $(`install -d ${IMAGEPARTS_PATH}/noda_build/sys`);
    $(`install -d ${IMAGEPARTS_PATH}/noda_build/sys_ex`);

    $(`rsync  -az --delete ${g.SPATH}/tmp/imageparts/noda_settings/ ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/necron`);
    $(`rsync  -az --delete ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/necron/ ${IMAGEPARTS_PATH}/noda_build/sys/`);
    $(`rsync  -az --delete ${g.SPATH}/${g.IMAGE_PATH}/rootfs/etc/necron/ ${IMAGEPARTS_PATH}/noda_build/sys_ex/`);
}

function CalcDirSize (cdir){
    echo(`Calc dirsize ${cdir}`);

    let s=execSync(`du -sb ${cdir}|cut -f1`);
    let BLOCK_SIZE=512
    let SIZE_IN_BLOCKS=(s/BLOCK_SIZE)+1;
    return BLOCK_SIZE*SIZE_IN_BLOCKS;
}

function syncNodeModules() {
    if(g.NECRON_PATH===undefined)
        g.NECRON_PATH=g.IMAGEPARTS+'/noda_build';

    if (g.NODE_MODULES_ROOT===undefined)
    {
        echo(`PreBuildFactoryImage Use default NODE_MODULES_ROOT [rsync -az --delete ${g.IMAGEPARTS}/noda_modules/node_modules/ ${g.NECRON_PATH}/node_modules]`);
        $(`rsync -az --delete ${g.IMAGEPARTS}/noda_modules/node_modules/ ${g.NECRON_PATH}/node_modules`);
    }
    else{
        echo(`PreBuildFactoryImage Use NODE_MODULES_ROOT ${g.NODE_MODULES_ROOT}`);
        $(`rm -r ${g.NECRON_PATH}/node_modules`);
        $(`ln -s ${g.NODE_MODULES_ROOT} ${g.NECRON_PATH}/node_modules`);
    }
}

module.exports={
    EditImagesBeforeGlobal,
    ConfigureSyncReplaces,
    ConfigureSSH,
    ConfigureConsole,
    ConfigureUdev,
    ConfigureFTP,
    ConfigureSystemd,
    EditImagesAfterGlobal,
    ConfigureDistro,
    ReGenVersion,
    CalcDirSize,
    syncNodeModules
}
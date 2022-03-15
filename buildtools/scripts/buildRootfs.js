let {$,cd,unCd,echo}=require('./utils');
let g=require('./global').getGlobal();
let path=require('path');
let fs=require('fs');

module.exports.run=()=>{
    $(`install -d ${g.SPATH}/tmp/imageparts/rootfs/`);
    echo(`Sync rootfs ${g.ORIGINAL_ROOTFS_PATH}/ to ${g.SPATH}/tmp/imageparts/rootfs/`);
    $(`rsync -az --delete ${g.ORIGINAL_ROOTFS_PATH}/ ${g.SPATH}/tmp/imageparts/rootfs/`);
    $(`rm -R ${g.SPATH}/tmp/imageparts/rootfs/etc/ppp/peers`);
    $(`ln -s /var/run ${g.SPATH}/tmp/imageparts/rootfs/etc/ppp/peers`);
}
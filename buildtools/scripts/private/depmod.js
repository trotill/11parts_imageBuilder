let {$,cd,unCd,echo}=require('./../utils');
let g=require('./../global').getGlobal();
let fs=require('fs');

module.exports.DepMod=(ROOT_DIR)=> {
    let vers= fs.readdirSync(ROOT_DIR+'/lib/modules');
    echo(`${globToBash(g)}depmod -b ${ROOT_DIR} ${vers[0]}`);
    $(`${globToBash(g)}depmod -b ${ROOT_DIR} ${vers[0]}`);
}
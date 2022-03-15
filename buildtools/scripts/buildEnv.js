let {$,cd,unCd}=require('./utils');
let g=require('./global').getGlobal();
let path=require('path');
let fs=require('fs');

module.exports.run=()=>{
    let ENVFILE_CFG=`${g.PRIVATE_PATH}/path/${g.CONFIG_NAME}.js`;
    if (fs.existsSync(ENVFILE_CFG)){
        console.log(`${ENVFILE_CFG} exist`);
        //require('./buildtools/env/make_env');
        //console.log('cross script generated');
    }
    else{
        console.log(`${ENVFILE_CFG} not exist`);
    }
}
let config=require('../../config');
let fs=require('fs');

let imgName=`${config.CPU_NAME}_${config.PROJECT_NAME}_${config.PROJECT_DISTRO}_${config.PROJECT_STOR}`;
let rdCfg=fs.readFileSync(`config`);
fs.writeFileSync(`${imgName}.js`,rdCfg);
fs.unlinkSync('config')
console.log("Config saved as",imgName);
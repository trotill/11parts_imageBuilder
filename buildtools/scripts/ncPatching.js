let {$,cd,unCd,echo}=require('./utils');
let g=require('./global').getGlobal();
let im=require('./private/images');
let path=require('path');
let fs=require('fs');

let run=() => {
    console.log('Run ncPatching');
    echo(`Select ./images/${g.imageBuilder}`);
    let imageBuilder=require(`./images/${g.imageBuilder}`);
    imageBuilder.EditImages(`${g.SPATH}/tmp/imageparts`);
    console.log('Exit ncPatching');
}

if (process.argv[1]===__filename){
    run();
}

module.exports= {
    run: run
}
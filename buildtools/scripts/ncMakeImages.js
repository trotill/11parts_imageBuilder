let {$,cd,unCd,echo}=require('./utils');
let g=require('./global').getGlobal();
let im=require('./private/images');
let path=require('path');
let fs=require('fs');

let run=() => {
    console.log('Run ncMakeImages');
    echo(`Make images ${g.IMAGE_PATH}`);
    $(`install -d ${g.IMAGE_PATH}`);
    let imageBuilder=require(`./images/${g.imageBuilder}`);
    imageBuilder.MakeImages(g.IMAGE_PATH);
    console.log('Exit ncMakeImages');
}
if (process.argv[1]===__filename){
    run();
}
module.exports= {
    run: run
}
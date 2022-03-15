console.log('run ncAll');


let ncSyncRepo=require('./ncSyncRepo');
let ncDeploy=require('./ncDeploy');
let ncPatching=require('./ncPatching');
let ncMakeImages=require('./ncMakeImages')
let {$,cd,unCd,echo}=require('./utils');

let execSync=require('child_process').execSync;


let run=()=>{

    console.log("run ncAll");

   // ncPatching.run();

   // ncDeploy.run();
    //ncMakeImages.run();

    if (ncSyncRepo.run()===0){
        ncDeploy.run();
        ncPatching.run();
        ncMakeImages.run();
    }
    else{
        console.log("Critical error, exit");
    }
}

if (process.argv[1]===__filename){
    run();
}


module.exports.run=run;

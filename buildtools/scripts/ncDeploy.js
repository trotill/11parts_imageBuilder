const buildEnv=require('./buildEnv');
const buildNode=require('./buildNode');
const buildRootfs=require('./buildRootfs');
const buildCnoda=require('./buildCnoda');
const buildBOS=require('./buildBOS');

let run=()=>{
    console.log('Run ncDeploy');
    buildEnv.run();
    buildNode.run();
    buildRootfs.run();
    buildCnoda.run();
    buildBOS.run();
    console.log('Exit ncDeploy');
}

if (process.argv[1]===__filename){
    run();
}

module.exports={
    run:run
}
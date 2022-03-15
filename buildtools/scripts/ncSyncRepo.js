let {$,cd,unCd}=require('./utils');
let g=require('./global').getGlobal();
let path=require('path');
let fs=require('fs')
let externalPath;
let syncExternal=()=>{
    if (g.EXTERNAL_REPO===undefined){
        console.log('EXTERNAL_REPO not use, skip sync');
        return 0;
    }

    console.log('sync external repo');
    cd(externalPath);
    $(`git clone ${g.EXTERNAL_REPO}`);
    cd(path.join(externalPath,g.EXTERNAL_REPO_NAME));
    $(`git checkout ${g.EXTERNAL_BRANCH}`);
    $(`git pull origin master`);
    return 0;
}
let syncUI=()=>{
    if (g.UI_REPO===undefined){
        console.log('UI_REPO not use, skip sync');
        return 0;
    }

    console.log(`sync ui ${g.UI_REPO_BRANCH} repo`);
    cd(externalPath);
   // console.log(`readdirSync ${externalPath}/web/necron/Projects/`);


    if (fs.existsSync(`${externalPath}/web/necron/Projects/`)){
        let fsres=fs.readdirSync(`${externalPath}/web/necron/Projects/`);
        console.log('Project dir content',fsres)
        if (fs.existsSync(`${externalPath}/web/necron/Projects/${g.UI_REPO_NAME}`)){
            if (fsres.length>1){
                fsres.forEach((item)=>{
                    $(`rm -r ${externalPath}/web/necron/Projects/${item}`)
                })
            }
        }
        else{
            fsres.forEach((item)=>{
                $(`rm -r ${externalPath}/web/necron/Projects/${item}`)
            })
        }
    }
    $(`git clone ${g.UI_REPO} ${externalPath}/web/necron/Projects/${g.UI_REPO_NAME}`);
    cd(`${externalPath}/web/necron/Projects/${g.UI_REPO_NAME}`);
    $(`git checkout -t origin/${g.UI_REPO_BRANCH}`);
    $(`git pull`);
    return 0;
}

let syncCnoda=()=>{
    if (g.CNODA_REPO===undefined){
        console.log('CNODA_REPO not use, skip sync');
        return 0;
    }
    console.log('sync cnoda repo');
    cd(externalPath);
    $(`git clone ${g.CNODA_REPO}`);
    cd(path.join(externalPath,g.CNODA_REPO_NAME))
    $(`git checkout ${g.CNODA_BRANCH}`);
    $(`git pull origin ${g.CNODA_BRANCH}`);
    return 0;
}

let syncEngine=()=>{
    if (g.CNODA_REPO===undefined){
        console.log('CNODA_REPO not use, skip sync');
        return 0;
    }
    console.log('sync cnoda repo');

    let ENGINE_REPO_NAME="engine";

    cd(path.join(externalPath,g.CNODA_REPO_NAME,"srvIoT","src"));
    $(`git clone ${g.ENGINE_REPO}`);
    cd(path.join(externalPath,g.CNODA_REPO_NAME,"srvIoT","src",ENGINE_REPO_NAME));

    let engineBranchName='master';
    if (g.ENGINE_BRANCH===undefined){
        console.log('Force select master branch for Cnoda engine');
    }
    else{
        engineBranchName=g.ENGINE_BRANCH;
        console.log(`Select ${engineBranchName} branch for Cnoda engine`);
    }

    if (g.ENGINE_COMMIT===undefined){
        console.log(`engine checkout ${engineBranchName}`);
        $(`git checkout ${engineBranchName}`);
        $(`git pull origin ${engineBranchName}`);
    }
    else{
        console.log(`engine checkout commit ${g.ENGINE_COMMIT}`);
        $(`git checkout ${g.ENGINE_COMMIT}`);
        $(`git pull origin ${g.ENGINE_COMMIT}`);
    }

    return 0;
}

let syncNode=()=>{
    if (g.NODE_REPO===undefined){
        console.log('NODE_REPO unset');
    }
    else{
        console.log(`Sync Node repo ${g.NODE_REPO}`);
        cd(externalPath);
        $(`git clone ${g.NODE_REPO}`);
        if (g.NODE_REPO_NAME===undefined){
            console.log('Error sync node repo, exit;')
            cd(g.SPATH);
            return -1;
        }
        cd(path.join(externalPath,g.NODE_REPO_NAME));
        if (g.NODE_COMMIT===undefined){
            $(`git checkout ${g.NODE_BRANCH}`);
            $(`git pull origin ${g.NODE_BRANCH}`);
        }
        else{
            $(`git checkout ${g.NODE_COMMIT}`);
            $(`git pull origin ${g.NODE_COMMIT}`);
        }
    }
    return 0;
}

let run=()=>{
    console.log('Run ncSyncRepo');
    externalPath=`${g.SPATH}/tmp/cache/external`;
    $(`install -d ${externalPath}`);
    let err=0;
    err|=syncExternal();
    err|=syncCnoda();
    err|=syncEngine();
    err|=syncNode();
    err|=syncUI();
    unCd();
    console.log('Exit ncSyncRepo');
    return err;
};

if (process.argv[1]===__filename){
    run();
}

module.exports.run=run;


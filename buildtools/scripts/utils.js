const execSync = require('child_process').execSync;
let cdPath=undefined;

let $=(cmd,path=undefined)=> {
    let out=""
    try {
        console.log(`->[${cmd}]`);
        if (path!==undefined)
            out=execSync(`(cd ${path};${cmd})`,{stdio: 'inherit'});
        else {
            if (cdPath===undefined)
                out = execSync(cmd, {stdio: 'inherit'});
            else
                out=execSync(`(cd ${cdPath};${cmd})`,{stdio: 'inherit'});
        }

        if (out!==null)
            console.log(`<-[${out}]`);
    }catch(e){
        console.log(`<-[except ${cmd}]`);
    }
    return out;
}
module.exports.$=$;

module.exports.globToBash=(glob)=>{
    let result="";
    for (let vname in glob){
        if (typeof glob[vname]!=='function')
            result+=`export ${vname}="${glob[vname]}";`;
    }
    return result;
}

module.exports.cd=(path)=>{
    cdPath=path;
    console.log(`->[cd ${path}]`);
}

module.exports.unCd=()=>{
    cdPath=undefined;
    console.log(`->[cd ~]`);
}

module.exports.echo=console.log;


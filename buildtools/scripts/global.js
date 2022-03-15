let buildInfo=require("../../config")
let configure=require("./private/configure")

let global={}

console.log("global",global)
//let global=buildInfo;
module.exports={
    getGlobal:()=>{
        global={...buildInfo,...configure.calkPath(buildInfo)};
        return global
    }
}
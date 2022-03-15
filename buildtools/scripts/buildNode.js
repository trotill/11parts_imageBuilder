let {$,cd,unCd,echo}=require('./utils');
let g=require('./global').getGlobal();
let path=require('path');
let fs=require('fs');

function grunt(){
    echo("Run grunt");
    cd(`${g.SPATH}/tmp/imageparts`);
    $(`cp ${g.SPATH}/buildtools/scripts/grunt/package.json ${g.SPATH}/tmp/imageparts`);
    $(`cp ${g.SPATH}/buildtools/scripts/grunt/Gruntfile.js ${g.SPATH}/tmp/imageparts`);
    $(`yarn`);
    $(`grunt`);
    unCd();
    echo("Grunt finished");

}

module.exports.run=()=>{
   let externalPath=path.join(g.SPATH,'tmp','cache','external');
   if (g.NODE_REPO===undefined){
       echo("NODE_REPO unset, skip BuildNode");
       $(`rm ${g.SPATH}/tmp/imageparts/noda_build/*`);
       $(`rm ${g.SPATH}/tmp/imageparts/noda_modules/node_modules/*`);
       $(`rm ${g.SPATH}/tmp/imageparts/noda_debug/*`);
   }
   else{
       $(`rm ${g.SPATH}/tmp/imageparts/noda/necron/compiled/*`);
       echo(`Sync ${externalPath}/${g.NODE_REPO_NAME}/necron/ to ${g.SPATH}/tmp/imageparts/noda/necron/`);
       $(`install -d ${g.SPATH}/tmp/imageparts/noda/necron`);
       $(`rsync -az --delete ${externalPath}/${g.NODE_REPO_NAME}/necron/Projects/${g.PROJECT_NAME}/default/settings/ ${g.SPATH}/tmp/imageparts/noda_settings`);
       //$(`rsync -az --delete ${externalPath}/${g.NODE_REPO_NAME}/necron/ ${g.SPATH}/tmp/imageparts/noda/necron/`);
       $(`rsync -az ${externalPath}/${g.NODE_REPO_NAME}/necron/ ${g.SPATH}/tmp/imageparts/noda/necron/`);
       cd(`${g.SPATH}/tmp/imageparts/noda/necron/`);

       $(`yarn`);
       cd(`${g.SPATH}/tmp/imageparts/noda/necron/Projects/${g.PROJECT_NAME}`);

       $(`yarn`);
       $(`npm run image`);
       unCd();

       $(`rm -r ${g.SPATH}/tmp/imageparts/nodaCompiled`);
       $(`rm -r ${g.SPATH}/tmp/imageparts/noda_build`);
       $(`install -d ${g.SPATH}/tmp/imageparts/nodaCompiled/necron/ui/visual/res`);
       $(`install -d ${g.SPATH}/tmp/imageparts/nodaCompiled/necron/ui/visual/external`);
       $(`install -d ${g.SPATH}/tmp/imageparts/nodaCompiled/necron/Jnoda`);
       $(`install -d ${g.SPATH}/tmp/imageparts/nodaCompiled/necron/devices`);
       $(`install -d ${g.SPATH}/tmp/imageparts/nodaCompiled/necron/web`);
       $(`install -d ${g.SPATH}/tmp/imageparts/nodaCompiled/necron/Projects/${g.PROJECT_NAME}`);

       $(`cp ${g.SPATH}/tmp/imageparts/noda/necron/*.json ${g.SPATH}/tmp/imageparts/nodaCompiled/necron`);
       $(`cp ${g.SPATH}/tmp/imageparts/noda/necron/*.js ${g.SPATH}/tmp/imageparts/nodaCompiled/necron`);
       $(`cp ${g.SPATH}/tmp/imageparts/noda/necron/*.html ${g.SPATH}/tmp/imageparts/nodaCompiled/necron`);
       $(`cp ${g.SPATH}/tmp/imageparts/noda/scripts ${g.SPATH}/tmp/imageparts/nodaCompiled/scripts -r`);
       $(`cp -r ${g.SPATH}/tmp/imageparts/noda/necron/Jnoda ${g.SPATH}/tmp/imageparts/nodaCompiled/necron`);
       $(`cp -r ${g.SPATH}/tmp/imageparts/noda/necron/devices ${g.SPATH}/tmp/imageparts/nodaCompiled/necron`);
       $(`cp -r ${g.SPATH}/tmp/imageparts/noda/necron/web ${g.SPATH}/tmp/imageparts/nodaCompiled/necron`);
       $(`cp -r ${g.SPATH}/tmp/imageparts/noda/necron/ui/external ${g.SPATH}/tmp/imageparts/nodaCompiled/necron/ui`);
       $(`cp -r ${g.SPATH}/tmp/imageparts/noda/necron/ui/visual/res ${g.SPATH}/tmp/imageparts/nodaCompiled/necron/ui/visual`);
       $(`cp -r ${g.SPATH}/tmp/imageparts/noda/necron/ui/visual/liblng ${g.SPATH}/tmp/imageparts/nodaCompiled/necron/ui/visual`);

       $(`cp -r ${g.SPATH}/tmp/imageparts/noda/necron/Projects/${g.PROJECT_NAME}/buildObj ${g.SPATH}/tmp/imageparts/nodaCompiled/necron/Projects/${g.PROJECT_NAME}`);
       $(`cp -r ${g.SPATH}/tmp/imageparts/noda/necron/Projects/${g.PROJECT_NAME}/default ${g.SPATH}/tmp/imageparts/nodaCompiled/necron/Projects/${g.PROJECT_NAME}`);
       $(`cp -r ${g.SPATH}/tmp/imageparts/noda/necron/Projects/${g.PROJECT_NAME}/styles ${g.SPATH}/tmp/imageparts/nodaCompiled/necron/Projects/${g.PROJECT_NAME}`);
       $(`rm -r  ${g.SPATH}/tmp/imageparts/nodaCompiled/necron/Projects/${g.PROJECT_NAME}/styles/shared`);
       $(`cp -r ${g.SPATH}/tmp/imageparts/noda/necron/Projects/${g.PROJECT_NAME}/Config.json ${g.SPATH}/tmp/imageparts/nodaCompiled/necron/Projects/${g.PROJECT_NAME}`);
       $(`cp -r ${g.SPATH}/tmp/imageparts/noda/necron/compiled ${g.SPATH}/tmp/imageparts/nodaCompiled/necron`);

       cd(`${g.SPATH}/tmp/imageparts/nodaCompiled/necron/Projects/`);

       $(`ln -s Projects/${g.PROJECT_NAME}/buildObj/ ../buildObj`);
       $(`ln -s ../Projects/${g.PROJECT_NAME}/styles/ ../ui/styles`);
       $(`ln -s ../Projects/${g.PROJECT_NAME}/Config.json ../Jnoda/Config.json`);

       if (!fs.existsSync(`${g.SPATH}/tmp/imageparts/nodaCompiled/necron/Projects/${g.PROJECT_NAME}/const.js`)){
           $(`ln -s web/const_def.js ../const.js`);
           echo('File const.js not found, use default!');
       }
       else{
           $(`ln -s Projects/${g.PROJECT_NAME}/const.js ../const.js`);
           echo(`File const.js found, use Projects/${g.PROJECT_NAME}/const.js`);
       }

       $(`cp -r ${g.SPATH}/tmp/imageparts/nodaCompiled ${g.SPATH}/tmp/imageparts/noda_build`)
        if ((g.COMPILE_JS!==undefined)&&(g.COMPILE_JS!==0)){
            grunt();
        }

       $(`install -d ${g.SPATH}/tmp/imageparts/noda_build/log`);
        $(`install -d ${g.SPATH}/tmp/imageparts/noda_build/download`);
       $(`install -d ${g.SPATH}/tmp/imageparts/noda_build/update`);
       $(`chmod augo+x ${g.SPATH}/tmp/imageparts/noda_build/necron/Jnoda/app/base/udhcpc.conf`);
       $(`chmod augo+x ${g.SPATH}/tmp/imageparts/noda_build/necron/Jnoda/app/base/udhcpc_debug.conf`);
       $(`chown -R www-data.www-data ${g.SPATH}/tmp/imageparts/noda_build/`);
   }
}
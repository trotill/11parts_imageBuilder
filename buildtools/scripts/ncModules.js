let {$,cd,unCd,echo,globToBash}=require('./utils');
let g=require('./global').getGlobal();

$(`install -d tmp/cache/external`);
$(`${globToBash(g)}${g.SPATH}/buildtools/scripts/dockerfiles/modulesinstall.sh ${g.SPATH}/tmp/imageparts/rootfs/`);
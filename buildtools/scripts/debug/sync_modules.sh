#!bin/sh
source initlib.sh

BuildExternal ""
rsync -az $SPATH/tmp/imageparts/rootfs/lib/modules/  lib/modules/
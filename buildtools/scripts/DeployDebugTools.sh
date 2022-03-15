#!bin/sh



IMAGE_PATH=$SPATH/images/$IMAGE_FOLDER
echo Place debug to $IMAGE_PATH/rootfs

rsync -az $SPATH/buildtools/scripts/debug/* $IMAGE_PATH/rootfs 
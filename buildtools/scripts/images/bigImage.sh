#!/bin/bash
source $SPATH/buildtools/scripts/images/yocto_big_image.sh
#source $NECRON_IMAGE_BASH_CALLBACK
IMAGE_PATH=images/$IMAGE_FOLDER
MakeImages $IMAGE_PATH
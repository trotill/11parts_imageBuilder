#!/bin/bash

echo run modulesinstall.sh
if [ -z "$KERN_COMPILER_ROOT" ]
then
	KERN_COMPILER_ROOT=$COMPILER_ROOT;
	KERN_COMPILER_ROOT_BIN=$COMPILER_ROOT_BIN;
fi

echo COMPILER_ROOT $COMPILER_ROOT COMPILER_ROOT_BIN $COMPILER_ROOT_BIN
echo KERN_COMPILER_ROOT $KERN_COMPILER_ROOT KERN_COMPILER_ROOT_BIN $KERN_COMPILER_ROOT_BIN

function dockerMakeBuildModules {
	dockerBUILD_SCRIPT='
		sudo su\n
		export ARCH='${KERN_ARCH}'\n
		export CROSS_COMPILE=/compiler/'${KERN_COMPILER_ROOT_BIN}'\n
		if [ $ARCH == "x86" ]
		then
			export LD_LIBRARY_PATH="/compiler/lib"
		fi
		cd /kernel\n
		make modules -j8\n
		make INSTALL_MOD_STRIP=1 modules_install INSTALL_MOD_PATH=/rootfs -j8
		kv=$(ls /rootfs/lib/modules)
		IFS=" " read -ra ARR <<< "$kv"
		for vers in "${ARR[@]}"; do
			echo "depmod for kernel ["$vers"]"
			echo depmod -b /rootfs $vers
			depmod -b /rootfs $vers
		done
	'
	echo -e "$dockerBUILD_SCRIPT"
}

function dockerBuild {
	echo docker run -i --rm -v $(pwd):/build -v ${KERN_COMPILER_ROOT}:/compiler -v $1:/rootfs -v ${KERNEL_PATH}:/kernel $DOCKER_IMAGE_NAME bash
	echo -e "$dockerBUILD_SCRIPT"| docker run -i --rm -v $(pwd):/build -v ${KERN_COMPILER_ROOT}:/compiler -v $1:/rootfs -v ${KERNEL_PATH}:/kernel $DOCKER_IMAGE_NAME bash
  # echo docker run -i --rm -v $(pwd):/build -v ${KERN_COMPILER_ROOT}:/compiler -v $1:/rootfs -v ${KERNEL_PATH}:/kernel $DOCKER_IMAGE_NAME	
	#echo -e "$dockerBUILD_SCRIPT">kern.sh
	#docker run -it --rm -v $(pwd):/build -v ${KERN_COMPILER_ROOT}:/compiler -v ${ORIGINAL_ROOTFS_PATH}:/rootfs -v ${KERNEL_PATH}:/kernel $DOCKER_IMAGE_NAME
}

dockerMakeBuildModules 
dockerBuild $1

echo "Build finish"
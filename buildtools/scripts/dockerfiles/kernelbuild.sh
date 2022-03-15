#!/bin/bash

echo run kernelbuild.sh

if [ -z "$KERN_COMPILER_ROOT" ]
then
	KERN_COMPILER_ROOT=$COMPILER_ROOT;
	KERN_COMPILER_ROOT_BIN=$COMPILER_ROOT_BIN;
fi

echo COMPILER_ROOT $COMPILER_ROOT COMPILER_ROOT_BIN $COMPILER_ROOT_BIN
echo KERN_COMPILER_ROOT $KERN_COMPILER_ROOT KERN_COMPILER_ROOT_BIN $KERN_COMPILER_ROOT_BIN

function dockerMakeBuildKernel {
	dockerBUILD_SCRIPT='
		sudo su\n
		export ARCH='${KERN_ARCH}'\n
		export CROSS_COMPILE=/compiler/'${KERN_COMPILER_ROOT_BIN}'\n
		if [ $ARCH == "x86" ]
		then
			export LD_LIBRARY_PATH="/compiler/lib"
		fi
		cd /kernel\n
		make '$1' -j8\n
	'
	echo -e "$dockerBUILD_SCRIPT"
}

function dockerSetDebug {
	dockerBUILD_SCRIPT='
		export ARCH='${KERN_ARCH}'\n
		export CROSS_COMPILE=/compiler/'${KERN_COMPILER_ROOT_BIN}'\n
		if [ $ARCH == "x86" ]
		then
			export LD_LIBRARY_PATH="/compiler/lib"
		fi
		cd /kernel\n
		sudo chown build.build /kernel -R
	'
	echo -e "$dockerBUILD_SCRIPT"
}

function dockerMakeBuildModules {
	rootfs=$1
	echo ModulesPath $rootfs
	dockerBUILD_SCRIPT='
		sudo su\n
		install -d '${rootfs}'
		export ARCH='${KERN_ARCH}'\n
		export CROSS_COMPILE=/compiler/'${KERN_COMPILER_ROOT_BIN}'\n
		if [ $ARCH == "x86" ]
		then
			export LD_LIBRARY_PATH="/compiler/lib"
		fi
		cd /kernel\n
		make modules -j8\n
		make INSTALL_MOD_STRIP=1 modules_install INSTALL_MOD_PATH='${rootfs}' -j8
		kv=$(ls '${rootfs}'/lib/modules)
		IFS=" " read -ra ARR <<< "$kv"
		for vers in "${ARR[@]}"; do
			echo "depmod for kernel ["$vers"]"
			echo depmod -b '${rootfs}' $vers
			depmod -b '${rootfs}' $vers
		done	
	'
	echo -e "$dockerBUILD_SCRIPT"
}
function dockerMakeBuildModulesDebug {
	rootfs=$1
	echo ModulesPath $rootfs
	dockerBUILD_SCRIPT='
		make modules -j8\n
		make INSTALL_MOD_STRIP=1 modules_install INSTALL_MOD_PATH='${rootfs}' -j8
		kv=$(ls '${rootfs}'/lib/modules)
		IFS=" " read -ra ARR <<< "$kv"
		for vers in "${ARR[@]}"; do
			echo "depmod for kernel ["$vers"]"
			echo depmod -b '${rootfs}' $vers
			depmod -b '${rootfs}' $vers
		done	
	'
	echo -e "$dockerBUILD_SCRIPT"
}

function dockerBuild {
	echo docker run -i --rm -v $(pwd):/build -v ${KERN_COMPILER_ROOT}:/compiler -v ${ORIGINAL_ROOTFS_PATH}:/rootfs -v ${KERNEL_PATH}:/kernel $DOCKER_IMAGE_NAME bash
	echo -e "$dockerBUILD_SCRIPT"| docker run -i --rm -v $(pwd):/build -v ${KERN_COMPILER_ROOT}:/compiler -v ${ORIGINAL_ROOTFS_PATH}:/rootfs -v ${KERNEL_PATH}:/kernel $DOCKER_IMAGE_NAME bash
	#docker run -i --rm -v $(pwd):/build -v ${KERN_COMPILER_ROOT}:/compiler -v ${ORIGINAL_ROOTFS_PATH}:/rootfs -v ${KERNEL_PATH}:/kernel $DOCKER_IMAGE_NAME bash

	#docker run -it --rm -v $(pwd):/build -v ${KERN_COMPILER_ROOT}:/compiler -v ${ORIGINAL_ROOTFS_PATH}:/rootfs -v ${KERNEL_PATH}:/kernel $DOCKER_IMAGE_NAME
}

function dockerKernelDebug {
	echo docker run -it --rm -v $(pwd):/build -v ${KERN_COMPILER_ROOT}:/compiler -v ${ORIGINAL_ROOTFS_PATH}:/rootfs -v ${KERNEL_PATH}:/kernel $DOCKER_IMAGE_NAME
	#echo -e "$dockerBUILD_SCRIPT"| docker run -i --rm -v $(pwd):/build -v ${KERN_COMPILER_ROOT}:/compiler -v ${ORIGINAL_ROOTFS_PATH}:/rootfs -v ${KERNEL_PATH}:/kernel $DOCKER_IMAGE_NAME bash
	echo -e "$dockerBUILD_SCRIPT">${KERNEL_PATH}/setCrossEnv.sh
	dockerMakeBuildModulesDebug "/kernel/modulesInstall"
	echo -e "$dockerBUILD_SCRIPT">${KERNEL_PATH}/setModulesInstall.sh
	docker run -it --rm -v $(pwd):/build -v ${KERN_COMPILER_ROOT}:/compiler -v ${ORIGINAL_ROOTFS_PATH}:/rootfs -v ${KERNEL_PATH}:/kernel $DOCKER_IMAGE_NAME
}

case "$1" in
	"modules")	 
	dockerMakeBuildModules "/root"
	dockerBuild ""
	;;
	"Image")
	dockerMakeBuildKernel ""
	dockerBuild ""
	;;
	"zImage")
	dockerMakeBuildKernel "zImage"
	dockerBuild ""
	;;
	"debug")
	dockerSetDebug ""
	dockerKernelDebug ""
	;;
esac
echo "Build finish"
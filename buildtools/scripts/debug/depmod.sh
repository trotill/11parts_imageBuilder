#!bin/sh

function DepMod {
	ROOT_DIR=$1
	LIBDIR=$1'/lib/modules'
	kv=$(ls $LIBDIR)
	IFS=' ' read -ra ARR <<< "$kv"
	for vers in "${ARR[@]}"; do
		echo "depmod for kernel ["$vers"]"
		echo depmod -b $ROOT_DIR $vers
		depmod -b $ROOT_DIR $vers
   		
	done

	
}

DepMod "/"
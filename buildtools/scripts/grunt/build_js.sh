#!bin/sh




function BuildJS
{
	pth=$PWD
	cp $SPATH/buildtools/scripts/grunt/Gruntfile.js	$SPATH/tmp/imageparts/Gruntfile.js
	cp $SPATH/buildtools/scripts/grunt/package.json	$SPATH/tmp/imageparts/package.json
	cd $SPATH/tmp/imageparts/
	rm -r $SPATH/tmp/imageparts/noda_build
	rm -r $SPATH/tmp/imageparts/noda_preinit
	mkdir $SPATH/tmp/imageparts/noda_build
	rm -r $SPATH/tmp/imageparts/noda_project
	mkdir $SPATH/tmp/imageparts/noda_project/

	cp -r $SPATH/tmp/imageparts/noda/necron/Projects/$PROJECT_NAME $SPATH/tmp/imageparts/noda_project/
	#npm install grunt
	npm install


	#find $SPATH/tmp/imageparts/noda -path "*.js" -exec sed -i 's/const /var /g' {} +
	grunt

	#rsync -az $SPATH/tmp/imageparts/noda_build/necron $SPATH/tmp/imageparts/noda 
	cd $pth
}

echo *************BuildJS!!!!

if [ 1 -eq "$COMPILE_JS" ];
  then
		echo Compile JS 
		BuildJS ""
  else
	if [ 1 -eq "$FORCE_COMPILE_JS" ];
	  then
		echo Force Compile JS 
		BuildJS ""
	  else

	  	 rm -r $SPATH/tmp/imageparts/noda_build
	  	 mkdir $SPATH/tmp/imageparts/noda_build
	  	 rsync -az $SPATH/tmp/imageparts/noda/necron $SPATH/tmp/imageparts/noda_build 	
		 echo Debug mode JS not compile!!!!
	 fi
fi

rsync -az $SPATH/tmp/imageparts/noda/necron/devices $SPATH/tmp/imageparts/noda_build/necron/devices 
chmod augo+x -R $SPATH/tmp/imageparts/noda_build/necron/devices/*
echo  chmod augo+x -R $SPATH/tmp/imageparts/noda_build/necron/devices/*
ls $SPATH/tmp/imageparts/noda_build/necron/devices/ -l

rm -r $SPATH/tmp/imageparts/noda_build/sys/
rm -r $SPATH/tmp/imageparts/noda_build/sys_ex/
cp -r $SPATH/tmp/imageparts/noda_settings $SPATH/tmp/imageparts/noda_build/sys/
cp -r $SPATH/tmp/imageparts/noda_settings $SPATH/tmp/imageparts/noda_build/sys_ex/
if [ -z $NODE_MODULES_ROOT ];
  then
  	echo Use default NODE_MODULES_ROOT
  else
  	echo Use NODE_MODULES_ROOT $NODE_MODULES_ROOT
  	rm -r $SPATH/tmp/imageparts/noda_build/node_modules
  	ln -s $NODE_MODULES_ROOT $SPATH/tmp/imageparts/noda_build/node_modules
  fi

var fs=require('fs')
var gcfg={};
const execSync = require('child_process').execSync;

console.log("args",process.argv);

function ParseCfg(conf_file){
	gcfg=require(conf_file);
	console.log("gcfg",gcfg);
}

function BuildBinUtils(cfg){
	var configure=`${cfg.binutils_src}/configure --build=${cfg.configure.build} `;
	if (cfg.configure.cross_compile!=undefined){
	 configure+=`--host=${cfg.configure.cross_compile.host} --target=${cfg.configure.cross_compile.target} `
	}
	configure+=`prefix=${cfg.configure.install_path}/usr `;
	configure+=`exec_prefix=${cfg.configure.install_path}/usr `;

	configure+=`bindir=${cfg.configure.install_path}/usr/bin/${cfg.configure.cross_compile.target} `;
	configure+=`sbindir=${cfg.configure.install_path}/usr/bin/${cfg.configure.cross_compile.target} `;
	configure+=`libexecdir=${cfg.configure.install_path}/usr/bin/${cfg.configure.cross_compile.target} `;
	
	configure+=`datadir=${cfg.configure.install_path}/usr/share `;

	configure+=`sysconfdir=${cfg.configure.install_path}/etc `;
	configure+=`sharedstatedir=${cfg.configure.install_path}/com `;
	configure+=`localstatedir=${cfg.configure.install_path}/var `;
	configure+=`libdir=${cfg.configure.install_path}/usr/lib/${cfg.configure.cross_compile.target} `;
	configure+=`includedir=${cfg.configure.install_path}/usr/include `;
	configure+=`oldincludedir=${cfg.configure.install_path}/usr/include `;
	configure+=`infodir=${cfg.configure.install_path}/usr/share/info `;
	configure+=`mandir=${cfg.configure.install_path}/usr/share/man `;
	for(var idx in cfg.configure.bitutils_opts){
		configure+='--'+cfg.configure.bitutils_opts[idx]+' ';
	}
	configure+=`--with-libtool-sysroot=${cfg.configure.install_path} `;
	configure+=`--with-sysroot=${cfg.configure.install_path} `;
	configure+=`--program-prefix=${cfg.configure.cross_compile.target}- `;

	console.log('binutils cfg',configure);
    execSync('sh '+configure,{stdio: 'inherit'});
    execSync(`make -j ${cfg.cpu_count}`,{stdio: 'inherit'});
}
function BuildGCC(cfg){
	var configure=`${cfg.gcc_src}/configure --build=${cfg.configure.build} `;
	if (cfg.configure.cross_compile!=undefined){
	 configure+=`--host=${cfg.configure.cross_compile.host} --target=${cfg.configure.cross_compile.target} `
	}
	configure+=`prefix=${cfg.configure.install_path}/usr `;
	configure+=`exec_prefix=${cfg.configure.install_path}/usr `;

	configure+=`bindir=${cfg.configure.install_path}/usr/bin/${cfg.configure.cross_compile.target} `;
	configure+=`sbindir=${cfg.configure.install_path}/usr/bin/${cfg.configure.cross_compile.target} `;
	configure+=`libexecdir=${cfg.configure.install_path}/usr/bin/${cfg.configure.cross_compile.target} `;
	
	configure+=`datadir=${cfg.configure.install_path}/usr/share `;

	configure+=`sysconfdir=${cfg.configure.install_path}/etc `;
	configure+=`sharedstatedir=${cfg.configure.install_path}/com `;
	configure+=`localstatedir=${cfg.configure.install_path}/var `;
	configure+=`libdir=${cfg.configure.install_path}/usr/lib/${cfg.configure.cross_compile.target} `;
	configure+=`includedir=${cfg.configure.install_path}/usr/include `;
	configure+=`oldincludedir=${cfg.configure.install_path}/usr/include `;
	configure+=`infodir=${cfg.configure.install_path}/usr/share/info `;
	configure+=`mandir=${cfg.configure.install_path}/usr/share/man `;
	configure+=`--with-libtool-sysroot=${cfg.configure.install_path} `;;
	configure+=`--program-prefix=${cfg.configure.cross_compile.target}- `;
	configure+=`--with-build-sysroot=${cfg.configure.install_path} `;

	for(var idx in cfg.configure.gcc_opts){
		configure+='--'+cfg.configure.gcc_opts[idx]+' ';
	}
	console.log('gcc cfg',configure);
    execSync('sh '+configure,{stdio: 'inherit'});
    execSync(`make -j ${cfg.cpu_count}`,{stdio: 'inherit'});
	//configure+=`--with-build-time-tools=`

}
function BuildEnvScript(cfg){
    var ccompile=false;
    if (cfg.configure.cross_compile!=undefined){
        ccompile=true;
    }
    var configure=`export SDKTARGETSYSROOT=${cfg.targetsysroot}\n`;
    configure+=`export PATH=${cfg.configure.install_path}/usr/bin\n`;
    configure+=`export PKG_CONFIG_SYSROOT_DIR=$SDKTARGETSYSROOT\n`;
    configure+=`export PKG_CONFIG_PATH=$SDKTARGETSYSROOT/usr/lib/pkgconfig:$SDKTARGETSYSROOT/usr/share/pkgconfig\n`;
    var compiler=cfg.configure.build;
    if (ccompile) {
        compiler=cfg.configure.cross_compile;
    }    
    
    configure+=`export CC="${compiler}-gcc  ${cfg.compiler_flags} --sysroot=$SDKTARGETSYSROOT"\n`;
    configure+=`export CXX="${compiler}-g++  ${cfg.compiler_flags} --sysroot=$SDKTARGETSYSROOT"\n`;
    configure+=`export CPP="${compiler}-gcc -E  ${cfg.compiler_flags} --sysroot=$SDKTARGETSYSROOT"\n`;
    configure+=`export AS="${compiler}-as "\n`;
    configure+=`export LD="${compiler}-ld  --sysroot=$SDKTARGETSYSROOT"\n`;
    configure+=`export GDB=${compiler}-gdb\n`;
    configure+=`export STRIP=${compiler}-strip\n`;
    configure+=`export RANLIB=${compiler}-ranlib\n`;
    configure+=`export OBJCOPY=${compiler}-objcopy\n`;
    configure+=`export OBJDUMP=${compiler}-objdump\n`;
    configure+=`export AR=${compiler}-ar\n`;
    configure+=`export NM=${compiler}-nm\n`;
    configure+=`export M4=m4\n`;
    configure+=`export TARGET_PREFIX=${compiler}-\n`;
    if (ccompile) 
        configure += `export CONFIGURE_FLAGS="--target=${cfg.configure.cross_compile} --host=${cfg.configure.cross_compile} --build=${cfg.configure.host} --with-libtool-sysroot=$SDKTARGETSYSROOT"\n`;
    
    
    configure+=`export CFLAGS=" -O2 -pipe"\n`;
    configure+='export CXXFLAGS="${BUILDSDK_CXXFLAGS}"\n';
    configure+='export LDFLAGS="-Wl,-O1"\n';
    configure+='export CPPFLAGS=""\n';
    configure+='export KCFLAGS="--sysroot=$SDKTARGETSYSROOT"\n';
    if (ccompile) {
        configure += `export ARCH=${cfg.arch}\n`;
        configure += `export CROSS_COMPILE=${cfg.configure.cross_compile}-\n`;
    }
    var env_setup=cfg.configure.install_path+'/env_setup.sh';
    fs.writeFileSync(env_setup,configure,'utf-8');
    console.log('create env script',env_setup);
}

function BuildEnvScript_x64_x64(cfg){
   
    var sdksysroot=cfg.targetsysroot;
    var tools_path=sdksysroot+"/usr/bin";
    var out_script_path=cfg.out_script_path;
    var compiler_flags=cfg.compiler_flags;
    var buildsdk_cxxflags="";

    var configure=`export SDKTARGETSYSROOT=${sdksysroot}\n`;
   // configure+=`export PATH=${sdksysroot}/bin:${sdksysroot}/sbin:${sdksysroot}/usr/bin:${sdksysroot}/usr/sbin`+":${PATH}\n";
    configure+=`export PKG_CONFIG_SYSROOT_DIR=$SDKTARGETSYSROOT\n`;
    configure+=`export PKG_CONFIG_PATH=$SDKTARGETSYSROOT/usr/lib/pkgconfig:$SDKTARGETSYSROOT/usr/share/pkgconfig\n`;

    
    configure+=`export CC="${cfg.cc_path} ${compiler_flags} --sysroot=$SDKTARGETSYSROOT"\n`;
    configure+=`export CXX="${cfg.cxx_path}  ${compiler_flags} --sysroot=$SDKTARGETSYSROOT"\n`;
    configure+=`export CPP="${cfg.cpp_path} -E  ${compiler_flags} --sysroot=$SDKTARGETSYSROOT"\n`;
    configure+=`export LD="${cfg.ld_path}  --sysroot=$SDKTARGETSYSROOT"\n`;
    
    configure+=`export CFLAGS=" -O2 -pipe"\n`;
    configure+='export CXXFLAGS=""\n';
    configure+=`export LDFLAGS="-Wl,-O1 -L${sdksysroot}/usr/lib -L${sdksysroot}/lib"\n`;
    configure+='export CPPFLAGS=""\n';
    configure+='export KCFLAGS="--sysroot=$SDKTARGETSYSROOT"\n';
    
    var env_setup=out_script_path;
    fs.writeFileSync(env_setup,configure,'utf-8');
    console.log('create env script',env_setup);
}

function BuildEnvScript_x64_yocto(cfg){
	var configure=`source ${cgf.envscript}`;

	var env_setup=cfg.out_script_path;
    fs.writeFileSync(env_setup,configure,'utf-8');
    console.log('create env script',env_setup);
}

if (process.argv.length>2){
	var cfg_file=process.argv[2];
	ParseCfg(cfg_file);
	if(gcfg.type=="x64_x64")
		BuildEnvScript_x64_x64(gcfg);
	if(gcfg.type=="x64_yocto")
		BuildEnvScript_x64_yocto(gcfg);
	//BuildGCC(gcfg);
	/*BuildEnvScript_x64_x64({
			type:"x64_x64",
			targetsysroot:"/e100/project/x86/SGA/build_sdk",
			compiler_flags:"",
			cc_path:"/usr/bin/gcc-9",
			cxx_path:"/usr/bin/g++-9",
			cpp_path:"/usr/bin/gcc-9",
			ld_path:"/usr/bin/ld",
			out_script_path:"/e100/project/x86/SGA/env_setup.sh"
	});*/
}
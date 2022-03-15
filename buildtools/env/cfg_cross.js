
module.exports = {
	cfg:{
		binutils_src:"/e100loc/project/x86/binutils2.28",
		gcc_src:"/e100loc/project/x86/gcc9.2.0/gcc-9.2.0",
		cpu_count:"8",
		targetsysroot:"/e100loc/project/imx6/necron/yocto/sdk_nano6ull/sysroots/armv7at2hf-neon-fslc-linux-gnueabi",
		compiler_flags:"-march=armv7-a -mthumb -mfpu=neon  -mfloat-abi=hard",
		arch:"arm",
		configure:{
			cross_compile:{
				host:'x86_64-linux-gnu',
				target:'arm-fslc-linux-gnueabi'
			},
			build:'x86_64-linux',
			install_path:'/e100loc/project/imx6/necron/buildtool/tmp/imageparts/',
			bitutils_opts:['disable-silent-rules','disable-dependency-tracking','disable-werror','enable-deterministic-archives','enable-plugins','enable-gold',
			'enable-ld=default','enable-threads','enable-64-bit-bfd','enable-poison-system-directories','disable-static','enable-nls'],
			gcc_opts:['disable-silent-rules','disable-dependency-tracking','with-gnu-ld','enable-shared','enable-languages=c,c++','enable-threads=posix','enable-multilib',
			'enable-c99','enable-long-long','enable-symvers=gnu','enable-libstdcxx-pch','without-local-prefix','enable-lto','enable-libssp','enable-libitm','disable-bootstrap',
			'disable-libmudflap','with-system-zlib','with-linker-hash-style=gnu','enable-linker-build-id','with-ppl=no','with-cloog=no','enable-checking=release','enable-cheaders=c_global',
			'without-isl','without-long-double-128','enable-poison-system-directories','disable-static','enable-nls','enable-initfini-array','without-headers']
		}
	}
}
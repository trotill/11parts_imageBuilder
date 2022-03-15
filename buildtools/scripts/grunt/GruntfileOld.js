//Стандартный экспорт модуля в nodejs
module.exports = function(grunt) {
  // Инициализация конфига GruntJS
  grunt.util.linefeed = "\u000A";
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    removelogging: {
        // the files inside which you want to remove the console statements 
        dist: {
          src: ['noda_test/**/*.js'],
          }
        },

    fixmyjs: {
      test: {
      files: [
        {
          expand: true, 
          cwd: 'noda/necron',
          src: ['*.js','devices/**/*.js','Jnoda/**/*.js','Projects/**/*.js','ui/**/*.js','web/**/*.js','!**/*.min.js'],
          dest: 'noda_fixes/necron',
          ext: '.js'
        }
      ]
    }
   },
   lineending: {               // Task 
    dist: {                   // Target 
      options: {              // Target options 
        eol: 'lf',
        overwrite: true
      },
      files: {  
        '':['noda_test/necron/**/*.js']
      }
      }
    },
    endline: {
        options: {
          footer:1,
          replaced:true,
        },
        default_options: {
            files: {
              '': [ 'noda_test/necron/**/*.js' ]
            }
        }
    },
    uglify: {
      options: {
        compress:{
          drop_console: true, 
          pure_funcs: [ 'logger.debug','GV.logger.debug'],

        },
        banner: '/*! Project founder and author: Ilya Gorchakov (contact me: https://11-parts.com)<%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
        //banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      build: {
        files:[{
          expand: true,
          cwd: 'noda/necron',
          //src:['**/*.js','*.js','!main_buildObj.js','!**/*.min.js'],
          //src:['**/*.js','!**/*.min.js'],
          src: ['*.js','devices/**/*.js','Jnoda/**/*.js','Projects/**/*.js','ui/**/*.js','web/**/*.js','!**/*.min.js'],
         
          dest: 'noda_build/necron'
        }]
      }
    },
    concat: {
            js_preinit: {
            	
                src: [ 
	                'noda_build/necron/ui/engine/**/*.js',
	                'noda_build/necron/ui/visual/**/*.js',
	                '!noda_build/necron/ui/visual/shared/material_base/**/*.js',
	                '!noda_build/necron/ui/visual/big/**/*.js',
	                '!noda_build/necron/ui/visual/little/**/*.js',
                  '!noda_build/necron/ui/visual/electron/**/*.js',
	                '!noda_build/necron/ui/**/*.fixed.js',
	                '!noda_build/necron/ui/**/*.min.js',
	                '!noda_build/necron/ui/**/*.slim.js',
	                '!noda_build/necron/ui/visual/shared/liblng/*'
                ],
                dest: 'noda_preinit/necron/ui/engine/preinit.min.js',
                options: {
                    separator: ';'
                }
            },
            js_big_material: {
            	src: [ 'noda_build/necron/ui/visual/big/material_base/*.js','noda_build/necron/ui/visual/shared/material_base/*.js'],
            	dest: 'noda_preinit/necron/ui/visual/big/material_base/material_big.min.js',
            },
            js_little_material: {
            	src: [ 'noda_build/necron/ui/visual/little/material_base/*.js','noda_build/necron/ui/visual/shared/material_base/*.js'],
            	dest: 'noda_preinit/necron/ui/visual/little/material_base/material_little.min.js',
            },
            js_electron_material: {
              src: [ 'noda_build/necron/ui/visual/electron/material_base/*.js','noda_build/necron/ui/visual/shared/material_base/*.js'],
              dest: 'noda_preinit/necron/ui/visual/electron/material_base/material_electron.min.js',
            },
            css_shared:{
            	src: [ 
            	'noda/necron/ui/visual/shared/**/*.css',
            	'!noda/necron/ui/visual/shared/material_base/**/*.css'
            	],
            	dest: 'noda_preinit/necron/ui/visual/shared/base/shared.css.tmp',
            },
            css_big_material:{
				      src: [ 'noda/necron/ui/visual/shared/material_base/*.css','noda/necron/ui/visual/big/material_base/**/*.css'],
            	dest: 'noda_preinit/necron/ui/visual/big/material_base/material_big.css.tmp',
            },
            css_little_material:{
            	src: [ 'noda/necron/ui/visual/shared/material_base/*.css','noda/necron/ui/visual/little/material_base/**/*.css'],
            	dest: 'noda_preinit/necron/ui/visual/little/material_base/material_little.css.tmp',
            },
            css_electron_material:{
              src: [ 'noda/necron/ui/visual/shared/material_base/*.css','noda/necron/ui/visual/electron/material_base/**/*.css'],
              dest: 'noda_preinit/necron/ui/visual/electron/material_base/material_electron.css.tmp',
            }
        },
    cssmin: {
    	big_material: {
    	  files:[{
            //'': ['noda_test/necron/**/*.css']
          	src: ['noda_preinit/necron/ui/visual/big/material_base/material_big.css.tmp'],
          	dest: 'noda_preinit/necron/ui/visual/big/material_base/material_big.min.css',
         }]
    	},
    	little_material: {
    	  files:[{
            //'': ['noda_test/necron/**/*.css']
          	src: ['noda_preinit/necron/ui/visual/little/material_base/material_little.css.tmp'],
          	dest: 'noda_preinit/necron/ui/visual/little/material_base/material_little.min.css',
         }]
    	},
      electron_material: {
        files:[{
            //'': ['noda_test/necron/**/*.css']
            src: ['noda_preinit/necron/ui/visual/electron/material_base/material_electron.css.tmp'],
            dest: 'noda_preinit/necron/ui/visual/electron/material_base/material_electron.min.css',
         }]
      },
        shared: {
          files:[{
            //'': ['noda_test/necron/**/*.css']
          src: ['noda_preinit/necron/ui/visual/shared/base/shared.css.tmp'],
          dest: 'noda_preinit/necron/ui/visual/shared/base/shared.min.css',
         }]
        }
    },
    clean: {

	  noda_preinit: ['noda_preinit/**/*.tmp'],
	  noda_engine: ['noda_build/necron/ui/engine/**/*.js'],
	  noda_shared_js: ['noda_build/necron/ui/visual/shared/**/*.js'],
	  noda_big_material_js: ['noda_build/necron/ui/visual/big/**/*.js'],
	  noda_little_material_js: ['noda_build/necron/ui/visual/little/**/*.js'],
    noda_electron_material_js: ['noda_build/necron/ui/visual/electron/**/*.js'],
	  noda_shared_css: ['noda_build/necron/ui/visual/shared/**/*.css'],
	  noda_big_material_css: ['noda_build/necron/ui/visual/big/**/*.css'],
	  noda_little_material_css: ['noda_build/necron/ui/visual/little/**/*.css'],
    noda_electron_material_css: ['noda_build/necron/ui/visual/electron/**/*.css'],
	  noda_preinit_styles: ['noda_preinit/necron/ui/styles/'],
	  noda_build_styles: ['noda_build/necron/ui/styles/'],
	  noda_buildObj1: ['noda_preinit/necron/buildObj/'],
	  noda_buildObj2: ['noda_build/necron/buildObj/']
	  //visual_big_little: ['noda_build/necron/ui/visual/big/*/*.js', 'noda_build/necron/ui/visual/little/*/*.js'],
	  //visual_shared: ['noda_build/necron/ui/visual/shared/base/*.js','noda_build/necron/ui/visual/shared/material_base/*.js']
	  //styles:['noda_build/necron/ui/styles/*']
	},
	copy:{
		main:{
			files:[
				{expand: true, cwd:'noda_project/',src: ['**/*.css'], dest: 'noda_build/necron/Projects/'},
				{expand: true, cwd:'noda_preinit/',src: ['**'], dest: 'noda_build/'},
				{expand: true, cwd:'noda/',src: ['**','!**/*.js','!**/*.css','!necron/ui/styles','!necron/buildObj'], dest: 'noda_build/'},
				{expand: true, cwd:'noda/',src: ['necron/ui/visual/shared/liblng/**'], dest: 'noda_build/'},
				{expand: true, cwd:'noda/',src: ['necron/ui/external/**'], dest: 'noda_build/'},
			]
		}	
	}
  });


  //Загрузка модулей, которые предварительно установлены
  //grunt.loadNpmTasks('grunt-contrib-jshint');
  //grunt.loadNpmTasks('grunt-contrib-concat');
  //grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-uglify-es');
  
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-copy');
  //grunt.loadNpmTasks('grunt-fixmyjs');
  //grunt.loadNpmTasks('grunt-lineending');
  //grunt.loadNpmTasks('grunt-endline');

  //Эти задания будут выполнятся сразу же когда вы в консоли напечатание grunt, и нажмете Enter
  //uglify 'removelogging'
  //'fixmyjs','removelogging','fixmyjs','uglify' lineending
  grunt.registerTask('default', ['uglify','concat','cssmin','clean','copy']);//,'uglify','clean']);

};
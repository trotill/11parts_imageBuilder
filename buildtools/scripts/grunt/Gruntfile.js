//Стандартный экспорт модуля в nodejs
module.exports = function(grunt) {
  // Инициализация конфига GruntJS
  grunt.util.linefeed = "\u000A";
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
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
          cwd: 'nodaCompiled/necron',
          //src:['**/*.js','*.js','!main_buildObj.js','!**/*.min.js'],
          //src:['**/*.js','!**/*.min.js'],
          src: ['*.js','Jnoda/*.js','Jnoda/**/*.js','Jnoda/**/**/*.js','web/**/*.js','!**/*.min.js'],
         
          dest: 'noda_build/necron'
        }]
      }
    }
  });


  //Загрузка модулей, которые предварительно установлены
  //grunt.loadNpmTasks('grunt-contrib-jshint');
  //grunt.loadNpmTasks('grunt-contrib-concat');
  //grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  

  //grunt.loadNpmTasks('grunt-fixmyjs');
  //grunt.loadNpmTasks('grunt-lineending');
  //grunt.loadNpmTasks('grunt-endline');

  //Эти задания будут выполнятся сразу же когда вы в консоли напечатание grunt, и нажмете Enter
  //uglify 'removelogging'
  //'fixmyjs','removelogging','fixmyjs','uglify' lineending
  grunt.registerTask('default', ['uglify']);//,'uglify','clean']);

};
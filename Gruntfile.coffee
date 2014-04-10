# Gruntfile.coffee

# constants
BUILD_PATH = 'build'
SRC_PATH = 'src'
CORE_PATH = 'lib/core/app'

# grunt
module.exports = (grunt) ->

  # init
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    clean: [BUILD_PATH]

    copy:
      main:
        files: [
          # lib/core
          {
            expand: true
            cwd: "#{CORE_PATH}/"
            src: ['**', '!**/smart.json', '!**/smart.lock', '!**/packages.json']
            dest: "#{BUILD_PATH}/"
            filter: 'isFile'
          }
          # src
          {
            expand: true
            cwd: "#{SRC_PATH}/"
            src: '**'
            dest: "#{BUILD_PATH}/"
            filter: 'isFile'
          }
        ]


  # plugins
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'


  # tasks
  grunt.registerTask 'build', ['clean', 'copy']
  grunt.registerTask 'run', ['clean', 'copy']
  grunt.registerTask 'default', ['build']

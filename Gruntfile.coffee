# Gruntfile.coffee

module.exports = (grunt) ->

  # init
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    build_path: 'build'
    dist_path:  '<%= build_path %>/dist'
    test_path:  '<%= build_path %>/test'
    src_path:   'src'
    core_path:  'lib/core'

    stylesheets_path: '<%= dist_path %>/public/stylesheets'


    clean: [ '<%= build_path %>' ]

    copy:
      src:
        files: [
            expand: true
            cwd: '<%= src_path %>/'
            src: '**'
            dest: '<%= dist_path %>'
            filter: 'isFile'
        ]
      core:
        files: [
            expand: true
            cwd: '<%= core_path %>/app'
            src: [
              '.meteor/**'
              'client/**'
              'lib/**'
              'smart.json'
            ]
            dest: '<%= dist_path %>'
        ]

    watch:
      dist:
        files: ['<%= src_path %>/**']
        tasks: [ 'copy:src', 'less', 'coffeelint' ]
      core:
        files: ['<%= core_path %>/**']
        tasks: [ 'copy:core', 'coffeelint' ]

    coffeelint:
      build:
        files:
          src: '<%= build_path %>/**/*.coffee'
        options:
          configFile: 'coffeelint.json'

    less:
      main:
        options:
          paths: '<%= stylesheets_path %>'
        files:
          '<%= stylesheets_path %>/index.css': '<%= stylesheets_path %>/index.less'

    bgShell:
      update:
        cmd: 'mrt update'
        bg: false
        options:
          stdout: true
          stderr: true
        execOpts:
          cwd: '<%= dist_path %>'
      run:
        cmd: 'meteor'
        bg: true
        options:
          stdout: true
          stderr: true
        execOpts:
          cwd: '<%= dist_path %>'


  # plugins
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-bg-shell'


  # tasks
  grunt.registerTask 'lint',    [ 'coffeelint' ]
  grunt.registerTask 'build',   [ 'clean', 'copy:src', 'copy:core', 'lint', 'less' ]
  grunt.registerTask 'update',  [ 'bgShell:update' ]
  grunt.registerTask 'run',     [ 'bgShell:run' ]
  grunt.registerTask 'default', [ 'build', 'update', 'run', 'watch' ]

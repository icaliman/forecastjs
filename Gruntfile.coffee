module.exports = (grunt) ->

  grunt.initConfig
    coffee:
      compile:
        files:
          'lib/forecast.js': ['src/forecastjs.coffee']
          'lib/meteo.js': 'src/meteo.coffee'
          'lib/adapter.js': 'src/adapter.coffee'
          'lib/data-collector.js': 'src/data-collector.coffee'
    mochaTest:
      options:
        reporter: 'nyan'
      src: ['test/test.coffee']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.registerTask 'default', ['coffee', 'mochaTest']
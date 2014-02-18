assert = require 'assert'
chai = require('chai')
forecast = require '../lib/forecastjs.js'

chai.should()

describe 'forecastjs', ->
  it 'test testing :)', ->

    s1 = 123
    s1.should.be.equal 123

    s1.should.be.equal 123

    "asd".should.be.equal "asd"

  it 'asdf', ->
    s1 = {asd: 123}
    s1.should.be.equal {asd: 123}

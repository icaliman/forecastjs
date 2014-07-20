Adapter = require './adapter'

class ForecastJS
  constructor: ->
    @adapters = []


  init: (compound) ->
    app = compound.app

    try
      conf = require app.root + "/config/forecastjs"
    catch e
      return console.error ">>>>>>>>>> Please configurate ForecastJS. Add file config/forecastjs[.coffee|.js]."

    conf = conf[app.get('env')]

    compound.on 'models', (models) =>
      if models[conf.meteo.db]
        @initMeteoModel(conf, models[conf.meteo.db])

        if conf and conf.services
          if conf.locations.adapter == 'file'
            geogroups = @getGeogroupsFromFile(app.root + conf.locations.source)

          else if conf.locations.adapter == 'memory'
            geogroups = conf.locations.source

          else if conf.locations.adapter == 'db'
            geogroups = @getGeogroupsFromDB(compound.models[conf.locations.source])

          for service in conf.services
            @initAdapter service, conf, geogroups, models[conf.meteo.db]
      else
        console.error "Please create model '#{models[conf.meteo.db]}' to store meteo data."


  initMeteoModel: (conf, Meteo) ->
    require('./meteo').init(conf, Meteo)


  initAdapter: (service, conf, geogroups, Meteo) ->
    adapters.push(new Adapter(service, conf, geogroups, Meteo))


  getGeogroupsFromFile: (path) ->
#    Get unique geogroups from file
    fs = require 'fs'
    u = {}
    geogroups = []
    for row in JSON.parse(fs.readFileSync(path))
      continue if u.hasOwnProperty row.geogroup
      geogroups.push row.geogroup
      u[row.geogroup] = true
    geogroups


  getGeogroupsFromDB: (Locations) ->
#    Locations.findAll()
    throw new Error("Not implemented. Must get geogroups from DB.");


  updateNow: ->
    for adapter in @adapters
      adapter.startNow()


module.exports = new ForecastJS()
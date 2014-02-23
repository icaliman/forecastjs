
exports.init = (compound) ->
  app = compound.app

  try
    conf = require app.root + "/config/forecastjs"
  catch e
    return console.error ">>>>>>>>>> Please configurate ForecastJS. Add file config/forecastjs[.coffee|.js]."

  conf = conf[app.set('env')]

  console.log JSON.stringify(conf, null, 4)

  compound.on 'models', (models) ->
    if models.Meteo
      exports.initMeteo(conf, models.Meteo)

      if conf and conf.services
        if conf.locations.adapter == 'file'
          fs = require 'fs'
#          Get unique geogroups from file
          u = {}
          geogroups = []
          for row in JSON.parse(fs.readFileSync(app.root + conf.locations.source))
            continue if u.hasOwnProperty row.geogroup
            geogroups.push row.geogroup
            u[row.geogroup] = true

        else if conf.locations.adapter == 'memory'
          geogroups = conf.locations.source

        else if conf.locations.adapter == 'db'
#          Locations = compound.models[conf.locations.source]
#          Locations.findAll()
          throw new Error("Not implemented. Must get geogroups from DB.");

        for service in conf.services
          exports.initAdapter service, conf, geogroups, models.Meteo


exports.initMeteo = (c, m) ->
  require('./meteo').init(c, m)


exports.initAdapter = (service, conf, geogroups, Meteo) ->
  require('./adapter').init(service, conf, geogroups, Meteo)

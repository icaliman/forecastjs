geomodel = require('geomodeljs').create_geomodel()

#process.on 'uncaughtException', (err)->
#  console.log err


class DataCollector
  constructor: (conf, adapter, geogroups, Meteo)->
    @interval = conf.update?.interval || 10
    @geogroups = geogroups
    @adapter = adapter
    @db = Meteo
    @started = false

  start: ->
    return console.log ">>>>> ForecastJS(openweathermap): Data collector is already started." if @started
    console.log ">>>>> ForecastJS(openweathermap): Started data collector"

    @started = true
    @hashes = (x for x in @geogroups)
    @doLoad()

  doLoad: ->
    if @hashes.length==0
      @started = false
      console.log ">>>>> ForecastJS(openweathermap): Finished data collector"
      return
    h = @hashes.pop()

    console.log ">>>>> ForecastJS(openweathermap): ", h, @hashes.length

    @loadHash(h)

  loadHash: (h)->
    obj = geomodel.compute_box(h)

    lat = (obj.getNorth() + obj.getSouth()) / 2
    lon = (obj.getEast() + obj.getWest()) / 2

    @adapter.getForecastLatLng lat, lon, (err, data) =>
      if err or not data
        console.log 'ForecastJS(openweathermap): request error: ' + err
        @hashes.push h
      else
        @saveData h, data

    @wait()

  saveData: (h, data) ->
    data.list.forEach (x) =>
      x.geogroup = h

      @db.updateForecast x, (err) =>
        console.log err if err

  wait: () ->
    n = @interval * 1000
    setTimeout (=> @doLoad()), n


module.exports = DataCollector
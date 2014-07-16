
exports.init = (conf, Meteo) ->

  Meteo.updateForecast = (json, cb) ->
    Meteo.findOne where: {geogroup: json.geogroup, date: json.date}, (err, old) ->
      return cb err if err

      json.updated = new Date

      if old
        delete json.date
        delete json.geogroup

        old.updateAttributes json, (err, row) ->
          cb(err)
      else
        Meteo.create json, (err, row) ->
          cb(err)

  Meteo.getDailyForecast = (geogroup, start_date, day_count, cb) ->

    start_date.setTime(start_date.getTime() - start_date.getTime() % 86400000) # 86400000 = 24 * 60 * 60 * 1000

    end_date = new Date(start_date.getTime() + day_count * 86400000 - 1)

    query =
      where:
        geogroup: geogroup
        date:
          between: [start_date, end_date]
      order: 'date'


#    console.log JSON.stringify query, null, 4

    Meteo.all query, (err, rows) ->
      return cb err if err

#      data = [{
#        date: new Date()
#        hours: [
#          2: {},
#          5: {},
#          8: {}
#        ]
#      }]

      data = []

      for row in rows
        timeDiff = row.date.getTime() - start_date.getTime()
        d = Math.floor(timeDiff / 86400000) # 86400000 = 24 * 60 * 60 * 1000
#        console.log d, row

        data[d] = data[d] || {
          date: new Date(start_date.getTime() + d*86400000)
          temp_min: 10000,
          temp_max: -10000
          hours: []
        } #{date: new Date(start_date.getTime() + d*86400000) , hours: []}

        #TODO: date.getHours() returneaza ora in dependenta de timezone, dar timezone pe server poate sa nu fie la fel ca pe client.
        #TODO: FIX: process.env.TZ = 'Europe/Chisinau'

        data[d].hours[row.date.getHours()] = row
        data[d].temp_min = row.temperature if row.temperature < data[d].temp_min
        data[d].temp_max = row.temperature if row.temperature > data[d].temp_max

      cb null, data

#  date = new Date()
#  date.setDate(new Date().getDate()-1)
#  Meteo.getDailyForecast 'e118e', date, 3, (err, data) ->
#    console.log "=-=-=-=-=-=-=", data
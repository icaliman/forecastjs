
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

    start_date.setHours(0,0,0,0)

    end_date = new Date(start_date.getTime() + day_count * 86400000 - 1)

#    console.log start_date
#    console.log end_date

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

        data[d] = data[d] || {hours:[]} #{date: new Date(start_date.getTime() + d*3600000) , hours: []}

        #TODO: date.getHours() returneaza ora in dependenta de timezone, dar timezone pe server poate sa nu fie la fel ca pe client.
        #TODO: FIX: process.env.TZ = 'Europe/Chisinau'

        data[d].hours[row.date.getHours()] = row

      cb null, data

#  date = new Date()
#  date.setDate(new Date().getDate()-1)
#  Meteo.getDailyForecast 'e118e', date, 3, (err, data) ->
#    console.log "=-=-=-=-=-=-=", data
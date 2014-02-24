
exports.init = (service, conf, geogroups, Meteo) ->

  console.log "Init adapter", service.adapter
  console.log "Geogroups: ", geogroups

  try
    Adapter = require(service.adapter)
    adapter = new Adapter
  catch e
    return console.error ">>>>> Adapter not found: " + service.adapter

  adapter.defaults service.defaults

  if service.update
    console.log "Start Cron Job"
    CronJob = require('cron').CronJob

    DataCollector = require('./data-collector')
    dataCollector = new DataCollector(service, adapter, geogroups, Meteo)

    try
      job = new CronJob service.update.cron, ( -> dataCollector.start()), null, false, conf.timezone
      job.start()
    catch e
      console.error ">>>>> cron pattern not valid: " + e
A wrapper for getting weather data from multiple sources.

Preia date meteo de la diferite servicii si le pune in BD in colectia Meteo.

In fisierul de configurare (FC) <code>config/forecastjs.coffee</code> se indica lista de servicii de unde se colecteaza datele.
Pot fi folosite mai multe servicii concomitent.

Tot in FC se indica pentru ce locatii sa se colecteze datele meteo.
Lista de locatii se da printr-o lista de geogroup-uri direct in FC, sau se indica calea catre un fisier JSON cu lista de locatii de genul:

    [
        {
            "id": 100,
            "name": "Chişinău",
            "parent": 0,
            "latitude": 47.021929410040514,
            "longitude": 28.861770629882812,
            "geogroup": "e118e",
            "type": "M"
        },
        ...
    ]

In viitor vor trebui preluate locatiile din BD.


Preluarea datelor meteo din BD (metoda "getDailyForecast" este adaugata de ForecastJS)

    Meteo.getDailyForecast(geogroup, start_date, day_count, function(err, data) {
        // in "data" sunt datele meteo pentru "day_count" zile incepand cu ziua indicata in "date"
    });


In fisierul de configurareLista de locatii pentru care se preia date meteo

Cerinte:
1. Poate fi folosit doar in CompoundJS + JugglingDB
2. Trebuie definit Meteo in <code>db/schema.coffee</code>

    Meteo = describe 'Meteo', ->
      property 'date', Date, {index: true}
      property 'geogroup', {index: true}
      property 'temperature', Number
      property 'humidity', Number, {dataType: 'float'}
      property 'pressure', Number, {dataType: 'float'}
      property 'wind_speed', Number, {dataType: 'float'}
      property 'wind_degrees', Number, {dataType: 'float'}
      property 'condition', String
      property 'sky', Number, {dataType: 'float'}
      property 'updated', Date, 'default': -> new Date

3. Trebuie creat fisierul de configurare <code>config/forecastjs.coffee</code>.

        module.exports =
          development:
            services: [
              adapter: 'fo-openweathermap'              # numele modulului de pe npmjs.org
              defaults:                                 # atribute adaugate in url-ul API-ului de unde se preiau date meteo
                APPID: 'xxxxx'
                units: 'metric'
              update:                                   # indica cand sa se faca update la datele meteo
                cron: '0 */20 * * * *'                  # pattern pentru modulul cron(https://www.npmjs.org/package/cron)
                interval: 8                             # intervalul dintre doua request-uri la serviciu, default = 10
            ]
            timezone: 'Europe/Chisinau'                 # folosit de adaptere pentru modulul cron
            locations:                                  # lista de locatii pentru
              adapter: 'memory'                         # file || memory (|| db?)
              source: ['e118e', 'e10ff']                # lista || calea catre fisierul JSON cu locatii (|| numele colectiei din DB?)

          test: ...
          production: ...

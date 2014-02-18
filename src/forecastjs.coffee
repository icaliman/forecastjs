# http://api.openweathermap.org/data/2.5/forecast/daily?lat=47&lon=29&units=metric&cnt=14
##
class Weather

  constructor: (options) ->
    @options = options

  kelvinToFahrenheit: (value) ->
    (@kelvinToCelsius(value) * 1.8) + 32

  kelvinToCelsius: (value) ->
    value - 273.15

  getCurrentLatLng: (latitude, longitude, callback) ->
    url = @_addParams "http://api.openweathermap.org/data/2.5/weather?lat=#{encodeURIComponent latitude}&lon=#{encodeURIComponent longitude}"
    @_getJSON url, (data) =>
      callback new Weather.Current(data)

  getForecastLatLng: (latitude, longitude, callback) ->
    url = @_addParams "http://api.openweathermap.org/data/2.5/forecast?lat=#{encodeURIComponent latitude}&lon=#{encodeURIComponent longitude}"
    @_getJSON url, (data) =>
      callback new Weather.Forecast(data)

  getCurrent: (city, callback) ->
    url = @_addParams "http://api.openweathermap.org/data/2.5/weather?q=#{encodeURIComponent city}"
    @_getJSON url, (data) =>
      callback new Weather.Current(data)

  getForecast: (city, callback) ->
    url = @_addParams "http://api.openweathermap.org/data/2.5/forecast/city?q=#{encodeURIComponent city}"
    @_getJSON url, (data) =>
      callback new Weather.Forecast(data)

  #
  # Private Methods
  #

  _getJSON: (url, callback) ->
    if isModule
      http.get URL.parse(url), (response) ->
        callback(response.body)
    else
      $.ajax
        url: url,
        dataType: "jsonp"
        success: callback

  _addParams: (url) ->
    for param, value of @options?.params
      url += "@#{param}=#{value}"
    url

module.exports = Weather
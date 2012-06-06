
geocoder = require('geocoder')

class Geo
    constructor: () ->
        @decoder = geocoder

    decode: (location, cb) ->

        @decoder.geocode(location, (err, data) ->
            cb(data)            
        )


exports.Geo = Geo


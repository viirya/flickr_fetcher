(function() {
  var Geo, geocoder;

  geocoder = require('geocoder');

  Geo = (function() {

    function Geo() {
      this.decoder = geocoder;
    }

    Geo.prototype.decode = function(location, cb) {
      return this.decoder.geocode(location, function(err, data) {
        return cb(data);
      });
    };

    return Geo;

  })();

  exports.Geo = Geo;

}).call(this);

(function() {
  var App, Callback, Flickr_Fetcher, Geo, MongoDatabase, assert, cli, exec, fs, http, prompt, sys;

  sys = require('sys');

  cli = require('cli');

  prompt = require('prompt');

  assert = require('assert');

  http = require('http');

  fs = require('fs');

  exec = require('child_process').exec;

  Flickr_Fetcher = require('./fetcher').Flickr_Fetcher;

  Callback = require('./callback').Callback;

  MongoDatabase = require('./mongo').MongoDatabase;

  Geo = require('./geo').Geo;

  App = (function() {

    function App(flickr_apikey, db_config) {
      this.flickr_apikey = flickr_apikey;
      this.db_config = db_config;
    }

    App.prototype.init = function(options, cb) {
      this.options = options;
      return this.decodeLocation(cb);
    };

    App.prototype.decodeLocation = function(cb) {
      var _this = this;
      if ((this.options.location != null)) {
        console.log("Decoding the geolocation of " + this.options.location);
        this.geo = new Geo;
        return this.geo.decode(this.options.location, function(data) {
          if ((data.results[0].geometry != null)) {
            console.log(data.results[0].geometry);
            _this.search_bbox = {
              min_lng: data.results[0].geometry.viewport.southwest.lng,
              min_lat: data.results[0].geometry.viewport.southwest.lat,
              max_lng: data.results[0].geometry.viewport.northeast.lng,
              max_lat: data.results[0].geometry.viewport.northeast.lat
            };
            _this.search_bbox_string = "" + _this.search_bbox.min_lng + "," + _this.search_bbox.min_lat + "," + _this.search_bbox.max_lng + "," + _this.search_bbox.max_lat;
            console.log("Constructing flickr bbox search argument: " + _this.search_bbox_string);
            _this.options.bbox = _this.search_bbox_string;
            return cb();
          } else {
            return console.log("Error in decoding geolocation");
          }
        });
      }
    };

    App.prototype.run = function() {
      var download_img, last_cb, parse_cb, simple_cb, store_cb,
        _this = this;
      simple_cb = function(results, next_cb) {
        if ((results.pages != null) && !(_this.pages != null)) {
          _this.pages = results.pages;
        }
        _this.cur_page = results.page;
        console.log("Obtain search results at page " + _this.cur_page + " of " + _this.pages);
        sys.puts(sys.inspect(results));
        return next_cb();
      };
      parse_cb = function(results, next_cb) {
        var download, photos, regex;
        regex = /http:\/\/(.*?)\/(.*)/;
        photos = results.photo.slice(0);
        download = function() {
          var download_cb, hostname, match, path, photo;
          photo = photos.pop();
          if ((photo != null)) {
            console.log("downloading " + photo.url_m);
            match = regex.exec(photo.url_m);
            hostname = match[1];
            path = '/' + match[2];
            download_cb = function(photo) {
              var command;
              command = "convert " + _this.options.imgdir + "/" + photo.id + ".jpg " + _this.options.tmpdir + "/" + photo.id + ".pgm";
              return exec(command, function(error, stdout, stderr) {
                if ((error != null)) {
                  return console.log('exec error: ' + error);
                } else {
                  command = "./bin/extract_features_64bit.ln -hesaff -sift -i " + _this.options.tmpdir + "/" + photo.id + ".pgm -o1 " + _this.options.feadir + "/" + photo.id + ".hes";
                  return exec(command, function(error, stdout, stderr) {
                    if ((error != null)) {
                      return console.log('exec error: ' + error);
                    } else {
                      return download();
                    }
                  });
                }
              });
            };
            return download_img(photo, hostname, path, download_cb);
          } else {
            return next_cb();
          }
        };
        return download();
      };
      download_img = function(photo, hostname, img_path, cb) {
        var options, request;
        options = {
          host: hostname,
          port: 80,
          path: img_path
        };
        return request = http.get(options, function(res) {
          var imagedata;
          imagedata = '';
          res.setEncoding('binary');
          res.on('data', function(chunk) {
            return imagedata += chunk;
          });
          return res.on('end', function() {
            return fs.writeFile("" + _this.options.imgdir + "/" + photo.id + ".jpg", imagedata, 'binary', function(err) {
              if (err) throw err;
              console.log('File saved.');
              return cb(photo);
            });
          });
        });
      };
      store_cb = function(results, next_cb) {
        var mongodb;
        if ((_this.options.collection != null)) {
          _this.db_config.collection = _this.options.collection;
        }
        if ((_this.db_config != null)) {
          console.log("Connecting database");
          mongodb = new MongoDatabase(_this.db_config);
          mongodb.init();
          return mongodb.operate(function(collection) {
            var count, photos, push_photo;
            console.log("Begin to store photo information into database");
            photos = results.photo.slice(0);
            count = 0;
            push_photo = function() {
              var photo;
              photo = photos.pop();
              if ((photo != null)) {
                return collection.insert(photo, {
                  safe: true
                }, function(err, result) {
                  assert.equal(null, err);
                  count++;
                  return push_photo();
                });
              } else {
                console.log("Total " + count + " photos inserted");
                return next_cb();
              }
            };
            return push_photo();
          });
        }
      };
      last_cb = function(results, next_cb) {
        if (_this.cur_page < _this.pages) {
          _this.options.page = _this.cur_page + 1;
          console.log("Continuing to search for page " + _this.options.page);
          _this.fetcher.init(_this.options);
          return _this.fetcher.search(_this.show.expose_cb());
        }
      };
      this.last = new Callback(last_cb);
      this.store = new Callback(store_cb, this.last);
      this.parse = new Callback(parse_cb, this.store);
      this.show = new Callback(simple_cb, this.parse);
      this.fetcher = new Flickr_Fetcher(this.flickr_apikey);
      this.fetcher.init(this.options);
      return this.fetcher.search(this.show.expose_cb());
    };

    return App;

  })();

  exports.App = App;

}).call(this);

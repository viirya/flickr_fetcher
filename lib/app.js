(function() {
  var App, Callback, Flickr_Fetcher, assert, cli, fs, http, mongo, prompt, sys;

  sys = require('sys');

  cli = require('cli');

  prompt = require('prompt');

  mongo = require('mongodb');

  assert = require('assert');

  http = require('http');

  fs = require('fs');

  Flickr_Fetcher = require('./fetcher').Flickr_Fetcher;

  Callback = require('./callback').Callback;

  App = (function() {

    function App(flickr_apikey) {
      this.flickr_apikey = flickr_apikey;
    }

    App.prototype.init = function(options) {
      this.options = options;
    };

    App.prototype.run = function() {
      var download_img, fetcher, parse, parse_cb, show, simple_cb,
        _this = this;
      simple_cb = function(results) {
        return sys.puts(sys.inspect(results));
      };
      parse_cb = function(results) {
        var download_cb, regex,
          _this = this;
        regex = /http:\/\/(.*?)\/(.*)/;
        download_cb = function() {
          var hostname, match, path, photo;
          photo = results.photo.pop();
          if ((photo != null)) {
            console.log("downloading " + photo.url_m);
            match = regex.exec(photo.url_m);
            hostname = match[1];
            path = '/' + match[2];
            return download_img(photo.id, hostname, path, download_cb);
          }
        };
        return download_cb();
      };
      download_img = function(photo_id, hostname, img_path, cb) {
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
            return fs.writeFile("" + _this.options.imgdir + "/" + photo_id + ".jpg", imagedata, 'binary', function(err) {
              if (err) throw err;
              console.log('File saved.');
              return cb();
            });
          });
        });
      };
      parse = new Callback(parse_cb);
      show = new Callback(simple_cb, parse);
      fetcher = new Flickr_Fetcher(this.flickr_apikey);
      fetcher.init(this.options);
      return fetcher.search(show.expose_cb());
    };

    return App;

  })();

  exports.App = App;

}).call(this);

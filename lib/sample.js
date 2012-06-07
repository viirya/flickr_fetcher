(function() {
  var App, Callback, MongoDatabase, Sampler, assert, cli, exec, fs, http, prompt, sys;

  sys = require('sys');

  cli = require('cli');

  prompt = require('prompt');

  assert = require('assert');

  http = require('http');

  fs = require('fs');

  exec = require('child_process').exec;

  Callback = require('./callback').Callback;

  MongoDatabase = require('./mongo').MongoDatabase;

  Sampler = (function() {

    function Sampler(options, db_config) {
      this.options = options;
      this.db_config = db_config;
    }

    Sampler.prototype.sample = function(callback) {
      var mongodb;
      if ((this.options.collection != null)) {
        this.db_config.collection = this.options.collection;
      }
      if ((this.db_config != null)) {
        console.log("Connecting database");
        mongodb = new MongoDatabase(this.db_config);
        mongodb.init();
        return mongodb.operate(function(collection) {
          var count, photos, stream;
          console.log("Begin to sample data from database");
          stream = collection.find({}, {
            id: true
          }).limit(100).streamRecords();
          photos = [];
          count = 0;
          stream.on("data", function(item) {
            console.log(item);
            count++;
            return photos.push(item);
          });
          return stream.on("end", function() {
            console.log("Total: " + count + " photos");
            return callback(photos);
          });
        });
      }
    };

    return Sampler;

  })();

  App = (function() {

    function App(db_config, options) {
      this.db_config = db_config;
      this.options = options;
    }

    App.prototype.init = function(cb) {
      return cb();
    };

    App.prototype.run = function() {
      var last_cb, simple_cb,
        _this = this;
      simple_cb = function(results, next_cb) {
        console.log(results);
        return next_cb();
      };
      last_cb = function(results, next_cb) {};
      this.last = new Callback(last_cb);
      this.show = new Callback(simple_cb, this.last);
      this.sampler = new Sampler(this.options, this.db_config);
      return this.sampler.sample(this.show.expose_cb());
    };

    return App;

  })();

  exports.App = App;

}).call(this);

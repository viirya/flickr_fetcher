(function() {
  var Database, Db, MongoDatabase, Server, assert, mongo,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  mongo = require('mongodb');

  assert = require('assert');

  Server = mongo.Server;

  Db = mongo.Db;

  Database = (function() {

    function Database(config) {
      this.config = config;
    }

    Database.prototype.init = function() {};

    Database.prototype.operate = function(cb) {};

    return Database;

  })();

  MongoDatabase = (function(_super) {

    __extends(MongoDatabase, _super);

    function MongoDatabase() {
      MongoDatabase.__super__.constructor.apply(this, arguments);
    }

    MongoDatabase.prototype.init = function() {
      this.server = new Server(this.config.host, this.config.port, this.config.options);
      return this.db = new Db(this.config.db, this.server);
    };

    MongoDatabase.prototype.operate = function(cb) {
      var _this = this;
      return this.db.open(function(err, db) {
        if (!err) {
          console.log(_this.config);
          return db.authenticate(_this.config.username, _this.config.password, function(err, result) {
            assert.equal(true, result);
            return db.collection(_this.config.collection, function(err, collection) {
              return cb(collection);
            });
          });
        } else {
          return console.log(err);
        }
      });
    };

    return MongoDatabase;

  })(Database);

  exports.MongoDatabase = MongoDatabase;

}).call(this);


mongo = require('mongodb')
assert = require('assert')

Server = mongo.Server
Db = mongo.Db

class Database
    constructor: (@config) ->
    init: ->
    operate: (cb) ->

class MongoDatabase extends Database

    init: ->
        @server = new Server(@config.host, @config.port, @config.options)
        @db = new Db(@config.db, @server)
    
    operate: (cb) -> 
        @db.open((err, db) =>
            if (!err)
                console.log(@config)
                db.authenticate(@config.username, @config.password, (err, result) =>
                    assert.equal(true, result)
        
                    db.collection(@config.collection, (err, collection) ->

                        cb(collection)

                    )
                )
            else
                console.log(err)
        )
        
    
exports.MongoDatabase = MongoDatabase


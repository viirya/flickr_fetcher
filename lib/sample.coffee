
sys = require('sys')
cli = require('cli')
prompt = require('prompt')
assert = require('assert')
http = require('http')
fs = require('fs')
exec = require('child_process').exec

Callback = require('./callback').Callback
MongoDatabase = require('./mongo').MongoDatabase

class Sampler

    constructor: (@options, @db_config) ->

    sample: (callback) ->
            if (@options.collection?)
                @db_config.collection = @options.collection

            if (@db_config?)
                console.log("Connecting database")
                mongodb = new MongoDatabase(@db_config)
                mongodb.init()
                mongodb.operate((collection) ->

                    console.log("Begin to sample data from database")

                    stream = collection.find({}, {id: true}).limit(100).streamRecords();

                    photos = []
                    count = 0
                    stream.on("data", (item) ->
                        console.log(item)
                        count++
                        photos.push(item)
                    )

                    stream.on("end", ->
                        console.log("Total: #{count} photos")
                        callback(photos)
                    )

                )

class App

    constructor: (@db_config, @options) ->

    init: (cb) ->
        cb()

    run: ->

        simple_cb = (results, next_cb) =>
            console.log(results)
            next_cb()

        last_cb = (results, next_cb) =>

        @last = new Callback(last_cb)
        @show = new Callback(simple_cb, @last)   

        @sampler = new Sampler(@options, @db_config)
        @sampler.sample(@show.expose_cb())

exports.App = App


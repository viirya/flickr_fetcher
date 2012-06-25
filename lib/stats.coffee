
sys = require('util')
cli = require('cli')
prompt = require('prompt')
assert = require('assert')
http = require('http')
fs = require('fs')
lazy = require('lazy')
clusterfck = require("clusterfck")
exec = require('child_process').exec

Callback = require('./callback').Callback

class StatisticSource

    constructor: (@options)

    compute: () ->
 

class StatisticSourceDir extends StatisticSource

    constructor: (@options) ->

    process_file: (filename, cb) ->

        readStream = fs.createReadStream(filename)
        readStream.on('error', (err) =>
            console.log(err)
        )
        count = 0
        hit = 0.0
        new lazy(readStream)
            .lines
            .forEach((line) =>
        
                line = line.toString()
                if (line == @options.groundtruth)
                    hit++    

                count++
        
            ).on('end', =>
                console.log("Total #{count} lines.")
                cb(hit / count)
            )
 
    compute: (cb) ->

        fs.readdir(@options.resultdir, (err, files) =>

            process = =>
                console.log("processing")
                file = files.pop()
                if (file?)
                    full_path = "#{@options.resultdir}/#{file}"
                    console.log("mode: #{file}")
                    @process_file(full_path, (precision) =>
                        console.log("#{precision}")
                        process()
                    )
                else
                    cb()

            process()
        ) 

class StatisticPerformer

    constructor: () ->

    run: (source, callback) ->
        results = source.compute(callback)

class App

    constructor: (@options) ->

    init: (cb) ->
        cb()

    run: (source) ->

        invoke_performer_cb = (results, next_cb) =>

            invoke_performer = =>
                next_cb()

            invoke_performer()

        last_cb = (results, next_cb) =>
            process.exit()

        @last = new Callback(last_cb)
        @jobs = new Callback(invoke_performer_cb, @last)
 
        @performer = new StatisticPerformer()
        @performer.run(source, @jobs.expose_cb())

exports.App = App
exports.StatisticSourceDir = StatisticSourceDir


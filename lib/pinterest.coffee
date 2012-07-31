
sys = require('util')
cli = require('cli')
prompt = require('prompt')
assert = require('assert')
http = require('http')
fs = require('fs')
exec = require('child_process').exec

class Pinterest

    constructor: () ->
        @options =
            host: 'pinterest.com',
            port: 80,
            method: 'GET'

    set: (params) ->
        if (params.keyword?)
            @options.path = "/search/?q=#{params.keyword}&page=#{params.page}"
        else
            @options.path = "/?page=#{params.page}"

        @cur_page = params.page    

    parse_html: (cb) ->

        pins = []

        html = @data

        pin_image_regex = /<a href=\"\/pin\/(.*?)\/\" class=\"PinImage ImgLink\">\s*?<img src=\"(.*?)\".*?\s*?.*?class=\"PinImageImg\".*?\/>\s*?<\/a>/m
        pin_like_count_regex = /<span class=\"LikesCount\">\s*?(\d*) (likes|like)\s*?<\/span>/m
        pin_comment_count_regex = /<span class=\"CommentsCount\">\s*?(\d*) (comments|comment)\s*?<\/span>/m
        pin_repin_count_regex = /<span class=\"RepinsCount\">\s*?(\d*) (repins|repin)\s*?<\/span>/m
    
        html_length = -1
 
        while (html_length != html.length)
            pin = {}

            html_length = html.length

            html = html.replace(pin_image_regex, (match, p1, p2) ->
                pin.pin_id = p1
                pin.image_url = p2
            )
            html = html.replace(pin_like_count_regex, (match, p1) ->
                pin.like_count = p1
            )
            html = html.replace(pin_comment_count_regex, (match, p1) ->
                pin.comment_count = p1
            )
            html = html.replace(pin_repin_count_regex, (match, p1) ->
                pin.repin_count = p1
            )

            if (pin.image_url?)
                pin.interestingness = (1000 - @cur_page) * 50 + (50 - pins.length) 
                pin.date = new Date().toString()
                pins.push(pin)

        cb(pins)
 

    request: (cb) ->

        if (@options.path?)
            @data = ''
            console.log(@options)
            http.get(@options, (res) =>
                console.log("Got response: " + res.statusCode)

                res.on('data', (chunk) =>
                    @data += chunk
                )
                res.on('end', () =>
                    @parse_html(cb)
                )
            ).on('error', (e) ->
                console.log("Got error: " + e.message)
            )
        else
            console.log("http request options not given.")


exports.Pinterest = Pinterest


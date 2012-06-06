
class Callback
    constructor: (@fn, @next_cb = null) ->

    call_next_cb: (results) ->
        return () =>
            if (@next_cb?)
                @next_cb.expose_cb()(results)

    expose_cb: ->
        return (results) =>
            @fn(results, @call_next_cb(results))

exports.Callback = Callback



class Callback
    constructor: (@fn, @next_cb = null) ->

    expose_cb: ->
        return (results) =>
            @fn(results)
            if (@next_cb?)
                @next_cb.expose_cb()(results)


exports.Callback = Callback


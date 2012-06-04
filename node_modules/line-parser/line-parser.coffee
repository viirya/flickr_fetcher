EventEmitter = require("events").EventEmitter

class LineParser extends EventEmitter
  constructor: ->
    @buffer = ""

  chunk: (data) ->
    potentialLines = data.split("\n")
    last = potentialLines.length-1
    
    for i in [0..last]
      line = ""
    
      if i == 0
        line = @buffer

      line += potentialLines[i]
      
      if i != last
        if line.charAt(line.length-1) == "\r"
          line = line.substr(0, line.length-1)
          
        this.emit "line", line
      else
        @buffer = line
    
    return null

module.exports = LineParser
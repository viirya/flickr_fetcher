(function() {
  var EventEmitter, LineParser;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  EventEmitter = require("events").EventEmitter;
  LineParser = (function() {
    __extends(LineParser, EventEmitter);
    function LineParser() {
      this.buffer = "";
    }
    LineParser.prototype.chunk = function(data) {
      var i, last, line, potentialLines;
      potentialLines = data.split("\n");
      last = potentialLines.length - 1;
      for (i = 0; 0 <= last ? i <= last : i >= last; 0 <= last ? i++ : i--) {
        line = "";
        if (i === 0) {
          line = this.buffer;
        }
        line += potentialLines[i];
        if (i !== last) {
          if (line.charAt(line.length - 1) === "\r") {
            line = line.substr(0, line.length - 1);
          }
          this.emit("line", line);
        } else {
          this.buffer = line;
        }
      }
      return null;
    };
    return LineParser;
  })();
  module.exports = LineParser;
}).call(this);

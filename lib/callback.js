(function() {
  var Callback;

  Callback = (function() {

    function Callback(fn, next_cb) {
      this.fn = fn;
      this.next_cb = next_cb != null ? next_cb : null;
    }

    Callback.prototype.call_next_cb = function(results) {
      var _this = this;
      return function() {
        if ((_this.next_cb != null)) return _this.next_cb.expose_cb()(results);
      };
    };

    Callback.prototype.expose_cb = function() {
      var _this = this;
      return function(results) {
        return _this.fn(results, _this.call_next_cb(results));
      };
    };

    return Callback;

  })();

  exports.Callback = Callback;

}).call(this);

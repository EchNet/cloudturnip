const extend = require("extend");

const DEFAULT_OPTIONS = {
  propertyName: 'cpu',
  threshold: 100000
}

module.exports = function(options) {

  options = extend({}, DEFAULT_OPTIONS, options);

  return {
    run: function(context) {
      return context.query("some query string").then((results) => {
        var total = 0;
        var count = results.items.length;
        for (var i = 0; i < count; ++i) {
          var instance = results.items[i];
          total += instance[options.propertyName];
        }
        var avg = total / count;
        if (avg > options.threshold) {
          context.emitViolation("instances borked", options);
        }
        return {}
      });
    }
  }
}

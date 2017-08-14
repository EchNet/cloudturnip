const Promise = require("promise");

function NoOp() {
}

NoOp.prototype = {
  run: function() {
    return Promise.resolve("null");
  }
}

module.exports = NoOp;

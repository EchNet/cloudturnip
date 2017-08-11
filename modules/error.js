function Error() {
  throw "You wanted an error, well here it is!"
}

Error.prototype = {
  run: function() {
  }
}

module.exports = Error;

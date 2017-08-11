// connectors.js

const extend = require("extend");
const Promise = require("promise");

const DEFAULTS = {
  redis: {
  },
  kafka: {
  },
  cht_svc_query: {
  }
}

const OVERRIDES = {
  development: {
  },
  production: {
  },
  test: {
  }
}

var env = process.env.NODE_ENV || "production";
var config = extend(true, { env: env }, DEFAULTS, OVERRIDES[env]);

module.exports = {
  moduleLoader: {
    loadModule: function(moduleName) {
      return new Promise(function(resolve, reject) {
        resolve(require("./modules/" + moduleName));
      });
    }
  }
}

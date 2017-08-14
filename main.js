const Promise = require("promise");
const Connectors = require("./connectors");

console.log("Eval started", new Date());

function parseArgs() {
  var inputs = {
    options: {},
    modules: []
  }
  process.argv.forEach((arg, index) => {
    if (index > 1) {
      var m = arg.match(/--(\w+)(=(\w+))?/);
      if (m) {
        name = m[1];
        value = m[2] ? m[3] : true;
        inputs.options[name] = value;
      }
      else if (arg.startsWith("-")) {
        throw "Unknown option: " + arg;
      }
      else {
        inputs.modules.push(arg);
      }
    }
  });
  return inputs;
}

function createContext(contextInfo) {
  return {
    query: function(queryString) {
      var queryData = { items: [ { cpu: 50 }, { cpu: 75 }, { cpu: 80 } ] }; // TODO: connect to query service.
      contextInfo.queryString = queryString;
      contextInfo.queryData = queryData;
      return Promise.resolve(queryData);
    },
    emitViolation: function(message, violationInfo) {
      // TODO: connect to kafka.
      console.log('violation', contextInfo, violationInfo);
      return Promise.resolve();
    }
  }
}

function runAllModules(inputs) {
  console.log("options", inputs.options);
  var modules = inputs.modules;
  return (function go() {
    return new Promise((resolve, reject) => {
      var moduleName = modules.shift();
      if (!moduleName) {
        resolve();
      }
      else {
        console.log("Load module", moduleName);
        resolve(Connectors.moduleLoader.loadModule(moduleName)
        .then((Module) => {
          console.log("Run module", moduleName);
          return new Module(inputs.options).run(createContext({ moduleName: moduleName }));
        })
        .then((results) => {
          console.log("Result of module", moduleName, "=", results);
          return go();
        }))
      }
    })
  })()
}

runAllModules(parseArgs()).then(() => {
  console.log("Eval finished", new Date());
  process.exit(0);
})
.catch((error) => {
  console.error(error);
  console.log("Eval exiting prematurely", new Date());
  process.exit(1);
})

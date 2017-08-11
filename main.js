const Promise = require("promise");
const Connectors = require("./connectors");

console.log("Cloudturnip started", new Date());

function getModuleList() {
  var modules = [];
  // All args are module names, for now.
  process.argv.forEach((arg, index) => {
    if (index > 1) {
      modules.push(arg);
    }
  });
  return modules;
}

function runAllModules() {
  var modules = getModuleList();
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
          return new Module().run();
        })
        .then((results) => {
          console.log("Result of module", moduleName, "=", results);
          return go();
        }))
      }
    })
  })()
}

runAllModules().then(() => {
  console.log("Cloudturnip finished", new Date());
  process.exit(0);
})
.catch((error) => {
  console.error(error);
  console.log("Cloudturnip exiting prematurely", new Date());
  process.exit(1);
})

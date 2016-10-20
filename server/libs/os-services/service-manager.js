const path = require('path');

const _services = Symbol('services');

const Service = require(path.join(__dirname, "data", "service"));
const Monitor = require(path.join(__dirname, "util", "monitor"));

class ServiceManager extends Monitor {
    constructor() {
        super();
        this[_services] = null;
    }

    get Services() { return this[_services]; }

    update() { super.update(); }
}

// If the OS is microsoft windows
if (/^win/.test(process.platform)) {
    const PowerShell = require(path.join(__dirname, "windows", "powershell"));
    const PS = new PowerShell();

    const CMD_ListServices = "Get-WmiObject win32_service | select Name, DisplayName, Description, State, @{Name=\"Path\"; Expression={$_.PathName.split('\"')[1]}}";

    class WindowsServiceManager extends ServiceManager {
        update() {
            var rawServices = PS.execToJSONSync(CMD_ListServices);
            var services = [];

            for (var i in rawServices) {
                var service = new Service(rawServices[i].Name, rawServices[i].Path);
                service.FullName = rawServices[i].DisplayName;
                service.Description = rawServices[i].Description;
                service.State = (rawServices[i].State == "Running" ? Service.States.RUNNING : (rawServices[i].State == "Stopped" ? Service.States.STOPPED : Service.States.UNKNOWN));
                services.push(service);
            }

            this[_services] = services;
            super.update();
        }
    }

    module.exports = WindowsServiceManager;
}
else {
    throw new Error("ServiceManager is not implemented for the operative system " + process.platform);
}
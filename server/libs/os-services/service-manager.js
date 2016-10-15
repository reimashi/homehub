const path = require('path');

const _timeout = Symbol('timeout');
const _services = Symbol('services');
const _lastUpdate = Symbol('lastUpdate');
const _timeoutHandler = Symbol('timeoutHandler');

const Service = require(path.join(__dirname, "service"));

class ServiceManager {
    constructor() {
        this[_timeout] = 5000;
        this[_timeoutHandler] = null;

        this[_services] = null;

        this.update();
    }

    get AutoUpdate() {
        return this[_timeoutHandler] != null;
    }

    set AutoUpdate(on) {
        if (on && !this.AutoUpdate) {
            this.update();
            this[_timeoutHandler] = setInterval(() => { this.update(); }, this[_timeout]);
        }
        else if (!on && this.AutoUpdate) {
            clearInterval(this[_timeoutHandler]);
            this[_timeoutHandler] = null;
        }
    }

    get RefreshTime() {
        return this[_timeout];
    }

    set RefreshTime(time) {
        this[_timeout] = Number(time);

        if (this.AutoUpdate) {
            clearInterval(this[_timeoutHandler]);
            this.update();
            this[_timeoutHandler] = setInterval(() => { this.update(); }, this[_timeout]);
        }
    }

    get Services() { return this[_services]; }
    get LastUpdate() { return this[_lastUpdate]; }

    update() {
        this[_lastUpdate] = new Date();
    }
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

            console.log(this.Services.map((elem) => elem.toJSON()));
        }
    }

    module.exports = WindowsServiceManager;
}
else {
    throw new Error("ServiceManager is not implemented for the operative system " + process.platform);
}
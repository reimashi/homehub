const path = require('path');

const _processes = Symbol('processes');

const Process = require(path.join(__dirname, "data", "process"));
const Monitor = require(path.join(__dirname, "util", "monitor"));

class ProcessManager extends Monitor {
    constructor() {
        super();
        this[_processes] = null;
    }

    get Processes() { return this[_processes]; }

    update() { super.update(); }
}

// If the OS is microsoft windows
if (/^win/.test(process.platform)) {
    const PowerShell = require(path.join(__dirname, "windows", "powershell"));
    const PS = new PowerShell();

    const CMD_ListProcesses = "Get-Process | select Name, Id, PriorityClass, ProductVersion, Path, Company, Product, Description, StartTime, Site";

    class WindowsProcessManager extends ProcessManager {
        update() {
            var rawProcesses = PS.execToJSONSync(CMD_ListProcesses);
            var processes = [];

            for (var i in rawProcesses) {
                var process = new Process(rawProcesses[i].Name, rawProcesses[i].Path);
                process.FullName = rawProcesses[i].Product ? rawProcesses[i].Product : process.FullName;
                process.Description = rawProcesses[i].Description ? rawProcesses[i].Description : "";
                process.Pid = rawProcesses[i].Id;
                processes.push(process);
            }

            this[_processes] = processes;
            super.update();

            console.log(this.Processes.map((elem) => elem.toJSON()));
        }
    }

    module.exports = WindowsProcessManager;
}
else {
    throw new Error("ProcessManager is not implemented for the operative system " + process.platform);
}
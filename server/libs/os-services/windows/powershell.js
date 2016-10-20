const spawn = require("child_process").spawn;
const spawnSync = require("child_process").spawnSync;
const EOL = require("os").EOL;

const arrayRegex = /^{\s*(?:'[^'\\]*(?:\\[\S\s][^'\\]*)*'|"[^"\\]*(?:\\[\S\s][^"\\]*)*"|[^,'"\s\\]*(?:\s+[^,'"\s\\]+)*)\s*(?:,\s*(?:'[^'\\]*(?:\\[\S\s][^'\\]*)*'|"[^"\\]*(?:\\[\S\s][^"\\]*)*"|[^,'"\s\\]*(?:\s+[^,'"\s\\]+)*)\s*)*}$/;

var parseFormatList = function (result) {
    var lines = result.split(EOL);
    var elements = [];

    var element = null;
    var lastKey = null;
    var lastValue = null;

    for (var i in lines) {
        var line = lines[i].trim();

        // If line empty, or contains :, flush property buffer
        if (line.includes(":") || line.length == 0) {
            if (lastKey != null) {
                // eleminamos saltos de linea

                if (lastValue == "null") { lastValue = null; }
                else if (lastValue == "True") { lastValue = true; }
                else if (lastValue == "False") { lastValue = false; }
                else if (arrayRegex.test(lastValue)) {
                    var braketCropped = lastValue.substring(1, lastValue.length - 1).trim();

                    if (braketCropped.length > 1) lastValue = braketCropped.split(",").map((elem) => elem.trim());
                    else lastValue = [];
                }

                element[lastKey] = lastValue;
                lastKey = null;
                lastValue = null;
            }
        }
        // If line empty, new element
        if (line.length == 0) {
            if (element != null) elements.push(element);
            element = null;
        }
        // If : in line, new property
        else if (line.includes(":")) {
            if (element == null) { element = {}; }

            var splitLine = line.split(":").map((elem) => elem.trim());

            lastKey = splitLine[0];
            lastValue = splitLine[1] ? splitLine[1] : null;
        }
        // If line not empty, add to property buffer
        else {
            lastValue += line;
        }
    }

    return elements;
}

class PowerShell {
    constructor() { }

    exec(command, cb) {

        return new Promise(function (resolve, reject) {
            var child = spawn("powershell.exe", String(command).split(" "));
            var out = "";
            var err = "";

            child.stdout.on("data", function (data) {
                out += data.toString('utf8');
                if (typeof cb == "function") { cb(null, data); }
            });

            child.stderr.on("data", function (data) {
                out += data.toString('utf8');
                if (typeof cb == "function") { cb(data); }
            });

            child.on("exit", function () {
                if (err == "") resolve(out);
                else reject(err);
            });

            child.stdin.end();
        });
    }

    execSync(command) {
        var result = spawnSync("powershell.exe", String(command).split(" "));

        if (result.error) throw result.error;
        else {
            return result.stdout.toString('utf8');
        }
    }

    execToJSON(command) {
        return this.exec(command + " | Format-List").then(parseFormatList);
    }

    execToJSONSync(command) {
        return parseFormatList(this.execSync(command + " | Format-List"));
    }

    GetService(name) { return this.execToJSON("Get-Service" + (name ? " " + String(name) : "")); }
    GetServiceSync(name) { return this.execToJSONSync("Get-Service" + (name ? " " + String(name) : "")); }
}

module.exports = PowerShell;
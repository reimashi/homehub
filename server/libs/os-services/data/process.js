const path = require('path');

const Program = require(path.join(__dirname, "program"));

const _pid = Symbol('pid');

class Process extends Program {
    constructor(name, path) {
        super(name, path);
        this[_pid] = null;
    }

    get Pid() { return this[_pid]; }
    set Pid(id) { this[_pid] = isNaN(id) ? null : Math.round(Number(id)); }

    toJSON() {
        var json = super.toJSON();

        json.pid = this.Pid;

        return json;
    }
}

module.exports = Process;
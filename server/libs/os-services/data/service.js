const path = require('path');

const Program = require(path.join(__dirname, "program"));

const _state = Symbol('state');

const ServiceStates = {
    UNKNOWN: "unknown",
    RUNNING: "running",
    STOPPED: "stopped"
};

class Service extends Program {
    constructor(name, path) {
        super(name, path);
        this[_state] = ServiceStates.UNKNOWN;
    }

    static get States() { return ServiceStates; }

    get State() { return this[_state]; }
    set State(state) {
        if (state == ServiceStates.RUNNING || state == ServiceStates.STOPPED) {
            this[_state] = state;
        }
        else { this[_state] = ServiceStates.UNKNOWN; }
    }

    toJSON() {
        var json = super.toJSON();

        json.state = this.State;

        return json;
    }
}

module.exports = Service;
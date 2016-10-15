const _name = Symbol('name');
const _longName = Symbol('longName');
const _description = Symbol('description');
const _state = Symbol('state');
const _exec = Symbol('timeout');

const ServiceStates = {
    UNKNOWN: "unknown",
    RUNNING: "running",
    STOPPED: "stopped"
};

class Service {
    constructor(name, path) {
        this[_name] = String(name);
        this[_longName] = String(name);
        this[_description] = "";
        this[_state] = ServiceStates.UNKNOWN;
        this[_exec] = (path) ? String(path) : null;
    }

    static get States() { return ServiceStates; }

    get Name() { return this[_name]; }

    get FullName() { return this[_longName]; }
    set FullName(fullname) { this[_longName] = String(fullname); }

    get Description() { return this[_description]; }
    set Description(desc) { this[_description] = String(desc); }

    get State() { return this[_state]; }
    set State(state) {
        if (state == ServiceStates.RUNNING || state == ServiceStates.STOPPED) {
            this[_state] = state;
        }
        else { this[_state] = ServiceStates.UNKNOWN; }
    }

    get Path() { return this[_exec]; }

    toJSON() {
        return {
            name: this.Name,
            fullname: this.FullName,
            description: this.Description,
            state: this.State,
            path: this.Path,
            _timestamp: new Date()
        };
    }
}

module.exports = Service;
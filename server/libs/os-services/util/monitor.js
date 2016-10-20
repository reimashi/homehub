const path = require('path');

const _timeout = Symbol('timeout');
const _lastUpdate = Symbol('lastUpdate');
const _timeoutHandler = Symbol('timeoutHandler');

class Monitor {
    constructor() {
        this[_timeout] = 5000;
        this[_timeoutHandler] = null;

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

    get LastUpdate() { return this[_lastUpdate]; }

    update() {
        this[_lastUpdate] = new Date();
    }
}

module.exports = Monitor;
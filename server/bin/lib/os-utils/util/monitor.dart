import "dart:async";

abstract class Monitor {
  StreamController<Monitor> _onRefreshEvent =
      new StreamController<Monitor>.broadcast();
  Timer _timeoutHandler = null;
  int _timeoutInterval = 5000;

  Stream<Monitor> get refreshEvent => this._onRefreshEvent.stream;

  DateTime _lastUpdate = null;

  int get refreshTime => this._timeoutInterval;
  void set refreshTime(int milliseconds) {
    this._timeoutInterval = milliseconds;
    if (this._timeoutInterval < 1) {
      this._timeoutInterval = 0;
      this.autoRefresh = false;
    }

    if (this.autoRefresh) {
      this._timeoutHandler.cancel();
      this._timeoutHandler = null;
      this.update();
      this._timeoutHandler = new Timer.periodic(
          new Duration(milliseconds: this.refreshTime), _Update);
    }
  }

  bool get autoRefresh => this._timeoutHandler != null;
  void set autoRefresh(bool on) {
    if (on && !this.autoRefresh) {
      this.update();
      this._timeoutHandler = new Timer.periodic(
          new Duration(milliseconds: this.refreshTime), _Update);
    } else if (!on && this.autoRefresh) {
      this._timeoutHandler.cancel();
      this._timeoutHandler = null;
    }
  }

  void update() {
    this._lastUpdate = new DateTime.now();
  }

  void _Update(Timer t) => update();
}

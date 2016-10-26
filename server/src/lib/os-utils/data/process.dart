import "./program.dart";

class Process extends Program {
  int _pid = -1;
  int _priority = 0;
  String _version = null;
  DateTime _startTime = null;
  int _memory = 0;

  Process(String name, String path, DateTime startTime) : super(name, path) {
    this._startTime = startTime;
  }

  int get pid => this._pid;
  void set pid(int id) {
    this._pid = id;
  }

  int get priority => this._priority;
  void set priority(int id) {
    this._priority = id;
  }

  String get version => this._version;
  void set version(String v) { this._version = (v == null || v.trim().length < 1) ? null : v.trim(); }

  DateTime get startTime => this._startTime;

  int get memory => this._memory;
  void set memory(int memory) { this._memory = memory < 0 ? 0 : memory; }

  static int parsePriority(String pname) {
    if (pname == null) return 0;
    switch (pname.toLowerCase()) {
      // Windows priority classes
      case "realtime":
        return 15;
      case "high":
        return 10;
      case "abovenormal":
        return 5;
      case "belownormal":
        return -5;
      case "idle":
        return -10;
      case "normal":
      default:
        return 0;
    }
  }
}

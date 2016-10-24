import "./program.dart";

class Process extends Program {
  int _pid = -1;
  int _priority = 0;

  Process(String name, String path) : super(name, path) {}

  int get pid => this._pid;
  void set pid(int id) {
    this._pid = id;
  }

  int get priority => this._priority;
  void set priority(int id) {
    this._priority = id;
  }

  static int parsePriority(String pname) {
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

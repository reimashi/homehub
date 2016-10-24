import "./program.dart";

enum ServiceStatus { Unknown, Running, Stopped }

class Service extends Program {
  ServiceStatus _status = ServiceStatus.Unknown;

  Service(String name, String path) : super(name, path) {}

  ServiceStatus get status => this._status;
  void set priority(ServiceStatus ss) {
    this._status = ss;
  }

  static ServiceStatus parseStatus(String sname) {
    switch (sname.toLowerCase()) {
      // Windows service states
      case "stopped":
        return ServiceStatus.Stopped;
      case "running":
        return ServiceStatus.Running;
      case "unknown":
      default:
        return ServiceStatus.Unknown;
    }
  }
}

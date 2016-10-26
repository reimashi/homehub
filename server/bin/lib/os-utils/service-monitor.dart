import 'dart:io';
import './data/service.dart';
import './util/windows/powershell.dart';
import './util/monitor.dart';

abstract class ServiceMonitor extends Monitor {
  List<Service> _services = new List<Service>();

  List<Service> get services => this._services;

  static ServiceMonitor GetOSManager() {
    if (new RegExp("^windows").hasMatch(Platform.operatingSystem)) {
      return new WindowsServiceMonitor();
    } else {
      throw new StateError(
          "ServiceManager is not implemented for the operative system " +
              Platform.operatingSystem);
    }
  }

  void update() { super.update(); }
}

class WindowsServiceMonitor extends ServiceMonitor {
  static final String _cmdListServices =
      "Get-WmiObject win32_service | select Name, DisplayName, Description, State, PathName | Format-List";

  void update() {
    IPowerShellResponse response = PowerShell.execSync(WindowsServiceMonitor._cmdListServices);
    List<Map<String, dynamic>> rawServices = PowerShellResponseParser.fromFormatList(response.toString());
    List<Service> services = new List<Service>();

    for (Map<String, dynamic> rawService in rawServices) {
      var srv = new Service(rawService["Name"], rawService["PathName"]);
      srv.fullName = rawService.containsKey("DisplayName") ? rawService["DisplayName"] : rawService["Name"];
      srv.description = rawService.containsKey("Description") ? rawService["Description"] : "";
      srv.status = Service.parseStatus(rawService["State"]);
      services.add(srv);
    }

    this._services = services;
    super.update();
  }
}

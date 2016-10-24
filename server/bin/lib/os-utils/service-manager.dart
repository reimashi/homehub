import 'dart:io';
import './data/service.dart';
import './util/windows/powershell.dart';
import './util/monitor.dart';

class ServiceManager extends Monitor {
  List<Service> _services = new List<Service>();

  List<Service> get services => this._services;

  static ServiceManager GetOSManager() {
    if (new RegExp("/^windows/").hasMatch(Platform.operatingSystem)) {
      return new WindowsServiceManager();
    } else {
      throw new StateError(
          "ServiceManager is not implemented for the operative system " +
              Platform.operatingSystem);
    }
  }
}

class WindowsServiceManager extends ServiceManager {
  static final String _cmdListServices =
      "Get-WmiObject win32_service | select Name, DisplayName, Description, State, PathName | Format-List";

  void Update() {
    IPowerShellResponse response = PowerShell.execSync(WindowsServiceManager._cmdListServices);
    List<Map<String, dynamic>> rawProcesses = PowerShellResponseParser.fromFormatList(response.toString());
    List<Service> services = new List<Service>();

    for (Map<String, dynamic> rawProcess in rawProcesses) {
      var srv = new Service(rawProcess["Name"], rawProcess["PathName"]);
      srv.FullName = rawProcess.containsKey("DisplayName") ? rawProcess["DisplayName"] : rawProcess["Name"];
      srv.Description = rawProcess.containsKey("Description") ? rawProcess["Description"] : "";
      srv.Status = Service.parseStatus(rawProcess["State"]);
      services.add(srv);
    }

    this._services = services;
    super.Update();
  }
}

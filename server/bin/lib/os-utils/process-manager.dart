import 'dart:io';
import './data/process.dart' as P;
import './util/windows/powershell.dart';
import './util/monitor.dart';

abstract class ProcessManager extends Monitor {
  List<P.Process> _processes = new List<P.Process>();

  List<P.Process> get processes => this._processes;

  static ProcessManager GetOSManager() {
    if (new RegExp("^windows").hasMatch(Platform.operatingSystem)) {
      return new WindowsProcessManager();
    } else {
      throw new StateError(
          "ProcessManager is not implemented for the operative system " +
              Platform.operatingSystem);
    }
  }

  void update() { super.update(); }
}

class WindowsProcessManager extends ProcessManager {
  static final String _cmdListProcess =
      "Get-Process | select Name, Id, PriorityClass, ProductVersion, Path, Description, @{Name=\"StartTime\";Expression={\$_.StartTime.ToString(\"yyyy-MM-dd hh:mm:ss.ffff\")}}, WS | Format-List";

  void update() {
    IPowerShellResponse response = PowerShell.execSync(WindowsProcessManager._cmdListProcess);
    List<Map<String, dynamic>> rawProcesses = PowerShellResponseParser.fromFormatList(response.toString());
    List<P.Process> processes = new List<P.Process>();

    for (Map<String, dynamic> rawProcess in rawProcesses) {
      var start = rawProcess["StartTime"] != null && rawProcess["StartTime"].trim().length > 0 ? DateTime.parse(rawProcess["StartTime"]) : null;
      var srv = new P.Process(rawProcess["Name"], rawProcess["Path"], start);
      srv.fullName = rawProcess.containsKey("DisplayName") ? rawProcess["DisplayName"] : rawProcess["Name"];
      srv.description = rawProcess.containsKey("Description") ? rawProcess["Description"] : "";
      srv.priority = P.Process.parsePriority(rawProcess["PriorityClass"]);
      srv.pid = rawProcess.containsKey("Id") ? int.parse(rawProcess["Id"]) : null;
      srv.memory = rawProcess.containsKey("WS") ? int.parse(rawProcess["WS"]) : 0;
      srv.version = rawProcess.containsKey("ProductVersion") ? rawProcess["ProductVersion"] : null;
      processes.add(srv);
    }

    this._processes = processes;
    super.update();
  }
}

import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as path;
import '../os-utils/util/monitor.dart';
import '../os-utils/process-monitor.dart';
import '../os-utils/service-monitor.dart';
import '../os-utils/data/service.dart';
import './application.dart';

class AppMonitor extends Monitor {
  static final String _appDefinitions = path.join(path.current, "app-definitions");

  List<Application> _apps = null;

  ProcessMonitor _pm = ProcessMonitor.GetOSManager();
  ServiceMonitor _sm = ServiceMonitor.GetOSManager();

  AppMonitor() {
    this.refreshTime = 15000;
  }

  List<Application> get apps => this._apps != null ? this._apps : new List();
  List<Application> get activeApps => apps.where((app) => app.active).toList();

  Future update() async {
    // If app definitions not loaded, load it
    if (this._apps == null) {
      this._apps = new List<Application>();

      var appPath = new Directory(_appDefinitions);
      Stream<FileSystemEntity> entityList = appPath.list(followLinks: false);

      await for (FileSystemEntity entity in entityList) {
        FileSystemEntityType type = await FileSystemEntity.type(entity.path);

        if (type == FileSystemEntityType.FILE && entity.path.endsWith(".json")) {
          var file = await new File(entity.path);
          var fileContent = await file.readAsString();
          this._apps.add(new Application.fromJSON(fileContent));
        }
      }
    }

    // Update app info
    await this._pm.update();
    await this._sm.update();


    for (Application app in this._apps) {
      var updated = false;

      for (var process in this._pm.processes) {
        if (app.isProcess(process.name)) {
          updated = true;
          app.active = true;
          app.runtimeInfo = process;
        }
      }

      if (!updated) for (var service in this._sm.services) {
        if (service.name == null) { stdout.writeln(service.path); exit(-1); }
        if (app.isService(service.name)) {
          updated = true;
          if (service.status == ServiceStatus.Running) { app.active = true; } else { app.active = false; }
          app.runtimeInfo = service;
        }
      }

      if (!updated) {
        app.active = false;
        app.runtimeInfo = null;
      }
    }

    super.update();
  }
}
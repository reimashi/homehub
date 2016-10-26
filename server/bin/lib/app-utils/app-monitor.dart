import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as path;
import '../os-utils/util/monitor.dart';
import '../os-utils/process-monitor.dart';
import '../os-utils/service-monitor.dart';

class Application {}

class AppMonitor extends Monitor {
  static final String _appDefinitions = path.join(path.current, "app-definitions");

  List<Application> _apps = null;

  ProcessMonitor _pm = ProcessMonitor.GetOSManager();
  ServiceMonitor _sm = ServiceMonitor.GetOSManager();

  AppMonitor() {
  }

  Future update() async {
    super.update();
  }
}
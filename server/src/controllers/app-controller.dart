import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_route/shelf_route.dart';
import '../lib/app-utils/app-monitor.dart';

import 'package:dartson/dartson.dart';
var DSON = new Dartson.JSON();

class AppController extends Routeable {
  final AppMonitor _appm = new AppMonitor();

  AppController() {
    _appm.refreshTime = 10000;
    _appm.autoRefresh = true;
    _appm.refreshEvent.listen((ev) { stdout.writeln("-> " + ev.toString()); });
  }

  void createRoutes(Router router) {
    router..get('/', getApps);
  }

  Response getApps(Request request) {
    return new Response.ok(DSON.encode(this._appm.activeApps), headers: {"Content-Type": "application/json"});
  }
}
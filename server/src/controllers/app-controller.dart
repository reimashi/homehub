import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_route/shelf_route.dart';
import '../lib/jwt/shelf_jwt.dart';
import './controller.dart';
import '../lib/app-utils/app-monitor.dart';

import 'package:dartson/dartson.dart';
var DSON = new Dartson.JSON();

class AppController extends Controller {
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
    stdout.writeln(request.context);
    ShelfJwtValidator auth = new ShelfJwtValidator(request);

    if (auth.loguedin) {
      return new Response.ok(auth.username);
    }
    else {
      return new Response.ok("Hoola");
    }
  }
}
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_route/shelf_route.dart';

import 'package:dartson/dartson.dart';
var DSON = new Dartson.JSON();

typedef Response ControllerCallback(Request req);

abstract class Controller extends Routeable {
  ControllerCallback auth(String group, ControllerCallback next, [ControllerCallback fallback]) {

  }
}
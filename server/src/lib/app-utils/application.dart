import 'package:dartson/dartson.dart';
import './app-definition.dart';

var DSON = new Dartson.JSON();

class Application {
  ApplicationDefinition _definition;
  bool active = false;
  var runtimeInfo = null;

  Application (ApplicationDefinition app) {
    this._definition = app;
  }

  Application.fromJSON (String json) {
    this._definition = DSON.decode(json, new ApplicationDefinition());
  }

  ApplicationDefinition get info => this._definition;

  bool isProcess (String processName) {
    return this._definition.processNames.contains(processName.trim());
  }

  bool isService (String serviceName) {
    return this._definition.serviceNames.contains(serviceName.trim());
  }

  String toJSON() => DSON.encode(this);
}
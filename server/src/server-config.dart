import 'dart:io';
import 'dart:async';
import 'package:dartson/dartson.dart';
var DSON = new Dartson.JSON();

class _HttpConfig {
  int port = 80;
  bool enabled = true;
}

class _HttpsConfig {
  int port = 443;
  bool enabled = false;
  String privatekey;
  String certificate;
}

class ServerConfig {
  _HttpConfig http = new _HttpConfig();
  _HttpsConfig https = new _HttpsConfig();
  String secret = "change_secret";

  static Future<ServerConfig> fromFile(String path) async {
    File file = await new File("config.json");
    String content = await file.readAsString();
    return DSON.decode(content, new ServerConfig());
  }

  static Future<ServerConfig> fromDefaultFile() async => fromFile("config.json");
}
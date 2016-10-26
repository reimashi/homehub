import 'dart:io';

import 'package:args/args.dart';
import 'package:redstone/redstone.dart' as web;

import './lib/os-utils/service-manager.dart';

void main(List<String> args) {
  var parser = new ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '8080');

  var result = parser.parse(args);

  var port = int.parse(result['port'], onError: (val) {
    stdout.writeln('Could not parse port value "$val" into a number.');
    exit(1);
  });

  web.setupConsoleLog();
  web.start(port: port);
}

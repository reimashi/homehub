import 'dart:io';

import 'package:args/args.dart';
import 'package:mojito/mojito.dart' as mojito;

void main(List<String> args) {
  var parser = new ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '8080');

  var result = parser.parse(args);

  var port = int.parse(result['port'], onError: (val) {
    stdout.writeln('Could not parse port value "$val" into a number.');
    exit(1);
  });

  var app = mojito.init(isDevMode: () => true);

  app.router.get('/hi', () => Platform.operatingSystem);

  app.start(port: port);
}

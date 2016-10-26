import 'dart:io';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart' as static;
import 'package:shelf_route/shelf_route.dart';
import 'package:args/args.dart';

import './controllers/app-controller.dart';

void main(List<String> args) {
  var parser = new ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '8080');

  var result = parser.parse(args);

  var port = int.parse(result['port'], onError: (val) {
    stdout.writeln('Could not parse port value "$val" into a number.');
    exit(1);
  });

  var staticHandler = static.createStaticHandler('../htdocs', defaultDocument: 'index.html');

  var myRouter = router()
    ..addAll(new AppController(), path: "/app");

  shelf.Handler cascadeHandler = new shelf.Cascade()
    .add(myRouter.handler)
    .add(staticHandler)
    .handler;

  io.serve(cascadeHandler, 'localhost', 8080).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
}
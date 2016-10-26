import 'dart:io';
import 'dart:async';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart' as static;
import 'package:shelf_route/shelf_route.dart';
import 'package:args/args.dart';

import './server-config.dart';

import './controllers/app-controller.dart';

Future main(List<String> args) async {
  var config = await ServerConfig.fromDefaultFile();

  var parser = new ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: config.http.port.toString())
    ..addOption('securePort', abbr: 's', defaultsTo: config.https.port.toString());

  var result = parser.parse(args);

  var port = int.parse(result['port'], onError: (val) {
    stdout.writeln('Could not parse port value "$val" into a number.');
    exit(1);
  });

  var securePort = int.parse(result['securePort'], onError: (val) {
    stdout.writeln('Could not parse securePort value "$val" into a number.');
    exit(1);
  });

  var staticHandler = static.createStaticHandler('../htdocs', defaultDocument: 'index.html');

  var myRouter = router()
    ..addAll(new AppController(), path: "/app");

  shelf.Handler cascadeHandler = new shelf.Cascade()
    .add(myRouter.handler)
    .add(staticHandler)
    .handler;

  if (config.http.enabled) {
    var server = await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port);
    io.serveRequests(server, cascadeHandler);
    print('Serving at http://${server.address.host}:${server.port}');
  }
  else if (config.https.enabled) {
    // TODO: Implement redirection to https
  }

  if (config.https.enabled) {
    SecurityContext serverContext = new SecurityContext()
      ..useCertificateChain(config.https.certificate)
      ..usePrivateKey(config.https.privatekey);

    var server = await HttpServer.bindSecure(InternetAddress.LOOPBACK_IP_V4, securePort, serverContext, backlog: 5);
    io.serveRequests(server, cascadeHandler);
    print('Serving at https://${server.address.host}:${server.port}');
  }
}
import 'dart:io';
import 'dart:async';
import 'package:option/option.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_auth/shelf_auth.dart';
import 'package:shelf_route/shelf_route.dart';
import 'package:uuid/uuid.dart';
import './controller.dart';

import 'package:dartson/dartson.dart';
var DSON = new Dartson.JSON();

class AuthController extends Controller {
  static SessionHandler sessionHandler = new JwtSessionHandler('homehub', new Uuid().v4(), AuthController.loadUser);

  static Middleware authMiddleware = authenticate([],
      sessionHandler: sessionHandler,
      allowHttp: true,
      allowAnonymousAccess: false);

  static Middleware _loginMiddleware = authenticate(
      [new UsernamePasswordAuthenticator(AuthController.loadUserPassword)],
      sessionHandler: sessionHandler,
      allowHttp: true,
      allowAnonymousAccess: false);

  void createRoutes(Router router) {
    router..post('/login', login, middleware: _loginMiddleware);
  }

  Response login (Request req) {
    return new Response.ok({});
  }

  static Future<Option<Principal>> loadUserPassword (String username, String password) {
    final validUser = username == 'root';

    final principalOpt =
    validUser ? new Some(new Principal(username)) : const None();

    return new Future.value(principalOpt);
  }

  static Future<Option<Principal>> loadUser(String username) {
    final validUser = username == 'root';

    final principalOpt =
    validUser ? new Some(new Principal(username)) : const None();

    return new Future.value(principalOpt);
  }
}
import 'dart:async';
import 'package:shelf/shelf.dart' as shelf;
import './jwt.dart';

class _JwtShelfContext {
  bool _hasToken = false;
  bool get hasToken => _hasToken;

  JwtPayload _payload = null;
  JwtPayload get payload => _payload;

  _JwtShelfContext() {}
  _JwtShelfContext.fromPayload(JwtPayload pl) {
    this._hasToken = true;
    this._payload = pl;
  }

  static String context_key = "shelf_jwt.context";
}

shelf.Request loadJwt(shelf.Request request, JwtCodec codec) {
  const String bearer = "Bearer ";
  Map<String, Object> oldContext = new Map.from(request.context);
  _JwtShelfContext context = new _JwtShelfContext();

  if (request.headers.containsKey("Authorization") && request.headers["Authorization"].startsWith(bearer)) {
    try {
      JwtPayload payload = codec.decode(request.headers["Authorization"].substring(bearer.length));
      context = new _JwtShelfContext.fromPayload(payload);
    }
    catch(exception) {
    }
  }

  oldContext..putIfAbsent(_JwtShelfContext.context_key, () => context);
  return request.change(context: oldContext);
}

shelf.Response saveJwt(shelf.Request request, shelf.Response response) {
  return response;
}

shelf.Middleware shelfJwt(JwtCodec codec) {
  return (shelf.Handler innerHandler) {
    return (shelf.Request request) {
      var r = loadJwt(request, codec);
      return new Future.sync(() => innerHandler(r)).then((shelf.Response response) {
        // persist session
        return saveJwt(r, response);
      });
    };
  };
}

class ShelfJwtValidator {
  JwtPayload _payload = null;

  bool _loguedin = false;
  bool get loguedin => _loguedin;

  String _username = "";
  String get username => _username;

  var _content = null;
  dynamic get content => _content;

  ShelfJwtValidator(shelf.Request req) {
    if (req.context.containsKey(_JwtShelfContext.context_key)) {
      var context = req.context[_JwtShelfContext.context_key] as _JwtShelfContext;
      this._payload = context.payload;

      this._username = this._payload.subject;
      this._content = this._payload.content;

      if (!this._payload.expirationTime.isBefore(new DateTime.now())) {
        this._loguedin = true;
      }
    }
  }
}
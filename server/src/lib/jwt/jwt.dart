import 'package:dartson/dartson.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'package:collection/collection.dart';
import 'dart:convert';

var _DSON = new Dartson.JSON();
var _ListEq = const ListEquality(const IdentityEquality());

enum JwtAlgorithm {
  HS256
}

@Entity()
class _JwtHeader {
  @Property(name:"typ")
  final String tokenType = "JWT";

  @Property(ignore:true)
  JwtAlgorithm algorithm = JwtAlgorithm.HS256;

  _JwtHeader.Default() {}

  _JwtHeader(JwtAlgorithm alg) {
    this.algorithm = alg;
  }

  @Property(name:"alg")
  String get alg {
    switch (this.algorithm) {
      case JwtAlgorithm.HS256:
      default:
        return "HS256";
    }
  }
}

@Entity()
class _JwtPayloadBean {
  @Property(name:"jti")
  String jti;

  @Property(name:"iss")
  String iss = null;

  @Property(name:"sub")
  String sub = null;

  @Property(name:"exp")
  String exp = null;

  @Property(name:"nbf")
  String nbf = null;

  @Property(name:"iat")
  String iat = null;

  @Property(name:"context")
  var context = null;

  _JwtPayloadBean() {}

  _JwtPayloadBean.fromPayload(JwtPayload pl) {
    jti = pl._id;
    iss = pl.issuer;
    sub = pl.subject;
    exp = pl._expirationTime.toIso8601String();
    nbf = pl._notbeforeTime.toIso8601String();
    iat = pl._creationTime.toIso8601String();
    context = pl.content;
  }
}

class JwtPayload {
  String _id = new Uuid().v4();
  DateTime _creationTime = new DateTime.now();
  DateTime _notbeforeTime = new DateTime.now();
  DateTime _expirationTime = new DateTime.now().add(new Duration(hours: 1));

  String subject;
  String issuer;
  var content;

  JwtPayload() {
  }

  JwtPayload.fromBean(_JwtPayloadBean data) {
    this._id = data.jti;
    this._creationTime = DateTime.parse(data.iat);
    this._notbeforeTime = DateTime.parse(data.nbf);
    this._expirationTime = DateTime.parse(data.exp);

    this.issuer = data.iss;
    this.subject = data.sub;
    this.content = data.context;
  }

  DateTime get expirationTime => this._expirationTime;
  void set expirationTime(DateTime dt) {
    if (dt == null) {
      throw new Exception("Expiration time cannot be null");
    }
    else this._expirationTime = dt;
  }
}

abstract class JwtCodec {
  JwtAlgorithm get algorithm;
  JwtPayload decode(String jwt);
  String encode(JwtPayload payload);
}

class JwtH256Codec extends JwtCodec {
  String _key;

  JwtAlgorithm get algorithm => JwtAlgorithm.HS256;

  JwtH256Codec(String key) {
    this._key = key;
  }

  JwtPayload decode(String jwt){
    List<String> splitted = jwt.split(".");

    var B64 = new Base64Codec();
    var H256 = new Hmac(sha256, UTF8.encode(this._key));

    String encoded = splitted[0] + "." + splitted[1];
    List<int> ssign = B64.decode(splitted[2]);
    var bsign = H256.convert(UTF8.encode(encoded)).bytes;

    if (_ListEq.equals(ssign, bsign)) {
      var bean = _DSON.decode(UTF8.decode(B64.decode(splitted[1])), new _JwtPayloadBean());
      return new JwtPayload.fromBean(bean);
    }
    else throw new Exception("Invalid signature");
  }

  String encode(JwtPayload payload){
    _JwtHeader header = new _JwtHeader(JwtAlgorithm.HS256);
    _JwtPayloadBean payloadBean = new _JwtPayloadBean.fromPayload(payload);

    var B64 = new Base64Codec();
    var H256 = new Hmac(sha256, UTF8.encode(this._key));

    var bheader = B64.encode(UTF8.encode(_DSON.encode(header)));
    var bpayload = B64.encode(UTF8.encode(_DSON.encode(payloadBean)));
    var encoded = bheader + "." + bpayload;
    var bsign = H256.convert(UTF8.encode(encoded)).bytes;
    return encoded + "." + B64.encode(bsign);
  }
}
import 'dart:async';
import './model.dart';
import 'package:dartson/dartson.dart';
import 'package:sembast/sembast.dart';

class WebData{
}

class WebModel extends Model {
  WebModel(Database db): super(db, "web") { }

  Future addWeb(WebData wd) async {
    return db.putRecord(new Record(this.store, wd));
  }

  Future<List<WebData>> getAllWebs() async {
    List<WebData> toret = new List<WebData>();

    await for (Record elem in this.store.records) {
      toret.add(elem.value as WebData);
    }

    return new Future(() => toret);
  }

  Future<List<WebData>> getPublicWebs() async {
    List<WebData> toret = new List<WebData>();

    this.store.findRecords(new Finder(filter: new Filter.)).then((List<Record> records) {

    })
      toret.add(elem.value as WebData);
    }

    return new Future(() => toret);
  }
}
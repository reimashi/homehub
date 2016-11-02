import 'package:sembast/sembast.dart';

class Model {
  final Database db;
  final String table;
  final Store store;

  Model(Database db, String table) : db = db, table = table, store = db.getStore(table);
}
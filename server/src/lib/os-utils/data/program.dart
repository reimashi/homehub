import 'package:path/path.dart' as Path;

class Program {
  String _name;
  String _fullName;
  String _description = null;
  String _path = "";

  Program(String name, String path) {
    this._name = name;
    this._fullName = name;
    this._path = path;

    if (this._name == null) {
      this._name = Path.basenameWithoutExtension(path);
    }
  }

  String get name => this._name;

  String get fullName => this._fullName != null ? this._fullName : "";
  void set fullName(String fn) {
    this._fullName = fn;
  }

  String get description => this._description != null ? this._description : "";
  void set description(String fn) {
    this._description = fn;
  }

  String get path => this._path;
}

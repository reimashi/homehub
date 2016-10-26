import 'dart:io';
import 'dart:async';
import 'dart:convert';

abstract class IPowerShellResponse {
  bool hasErrors();
  List<String> errors();
  String toString();
}

class PowerShellResponse implements IPowerShellResponse {
  static final _EOL = "\r\n";

  List<String> _out = new List<String>();
  List<String> _err = new List<String>();

  PowerShellResponse() {}
  PowerShellResponse.fromProcessResult(ProcessResult pr) {
    this._out = pr.stdout.toString().split(_EOL);
    this._err = pr.stderr.toString().length > 0 ? pr.stderr.toString().split(_EOL): new List<String>();
  }

  void addLine(String line) {
    this._out.add(line);
  }

  void addError(String line) {
    this._err.add(line);
  }

  bool hasErrors() => this._err.length > 0;
  List<String> errors() => this._err;
  List<String> lines() => this._out;
  String toString() => this._out.join(_EOL);
}

class PowerShellResponseParser {
  static final RegExp _arrayRegex = new RegExp("/^{\\s*(?:\'[^\'\\\\]*(?:\\\\[\\S\\s][^\'\\\\]*)*\'|\"[^\"\\\\]*(?:\\\\[\\S\\s][^\"\\\\]*)*\"|[^,\'\"\\s\\\\]*(?:\\s+[^,\'\"\\s\\\\]+)*)\\s*(?:,\\s*(?:\'[^\'\\\\]*(?:\\\\[\\S\\s][^\'\\\\]*)*\'|\"[^\"\\\\]*(?:\\\\[\\S\\s][^\"\\\\]*)*\"|[^,\'\"\\s\\\\]*(?:\\s+[^,\'\"\\s\\\\]+)*)\\s*)*}\$/");

  static List<Map<String, dynamic>> fromFormatList(String result) {
    List<String> lines = result.split(PowerShellResponse._EOL);
    List<Map<String, dynamic>> elements = new List<Map<String, dynamic>>();

    Map<String, dynamic> element = new Map<String, dynamic>();
    String lastKey = null;
    var lastValue = null;

    for (var i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      // If line empty, or contains :, flush property buffer
      if (line.contains(":") || line.length == 0) {
        if (lastKey != null) {
          // eleminamos saltos de linea
          if (lastValue == "null") { lastValue = null; }
          else if (lastValue == "True") { lastValue = true; }
          else if (lastValue == "False") { lastValue = false; }
          else if (lastValue.runtimeType == String && PowerShellResponseParser._arrayRegex.hasMatch(lastValue)) {
            String braketCropped = lastValue.substring(1, lastValue.length - 1).trim();

            if (braketCropped.length > 1) {
              lastValue = braketCropped.split(",").map((String elem) => elem.trim());
            }
            else {
              lastValue = [];
            }
          }

          element.putIfAbsent(lastKey, () => lastValue);
          lastKey = null;
          lastValue = null;
        }
      }

      // If line empty, new element
      if (line.length == 0) {
        if (element != null && element.isNotEmpty) { elements.add(element); }
        element = null;
      }
      // If : in line, new property
      else if (line.contains(":")) {
        if (element == null) { element = new Map(); }

        var splitLine = line.split(":");
        lastKey = splitLine[0].trim();

        splitLine = splitLine.sublist(1).join(":").trim();
        lastValue = splitLine.length > 0 ? splitLine : null;
      }
      // If line not empty, add to property buffer
      else {
        lastValue += line;
      }
    }

    return elements;
  }
}

class PowerShell {
  PowerShell() {}

  static Future<IPowerShellResponse> exec(String command) async {
    return Process
      .run("powershell.exe", command.split(" "))
      .then((ProcessResult pr) => new PowerShellResponse.fromProcessResult(pr));
  }

  static IPowerShellResponse execSync(String command) {
    ProcessResult pr = Process.runSync("powershell.exe", command.split(" "));
    return new PowerShellResponse.fromProcessResult(pr);
  }
}
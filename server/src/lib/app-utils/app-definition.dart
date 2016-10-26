class ServiceDefinition {
  String type;
  int defaultPort;
}

class ImageDefinition {
  String type;
  String path;
}

class ApplicationDefinition {
  String name;
  String license;
  String web;
  String publisher;
  List<ImageDefinition> images;
  List<String> processNames;
  List<String> serviceNames;
  List<ServiceDefinition> services;
}
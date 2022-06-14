import 'dart:async';

class BlocData {
  var _patronController = StreamController<Map<String,dynamic>>.broadcast();
  Stream<Map<String,dynamic>> get outList => _patronController.stream;
  Sink<Map<String,dynamic>> get inList => _patronController.sink;

  void dispose() {
    _patronController.close();
  }
}
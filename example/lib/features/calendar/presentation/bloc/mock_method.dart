import 'dart:async';

import 'package:flutter/services.dart';

///mock platform channel method
class MockMethod {
  ///stream controller for method call
  StreamController<MethodCall> streamController =
  StreamController<MethodCall>();

  ///return the stream of method call
  Stream<MethodCall> get stream => streamController.stream;

  ///dispose the stream
  void dispose() {
    streamController.close();
  }

  /// invoke method
  void invokeMethod(String methodName, Object? data) {
    const MethodChannel('com.example.demo/data').invokeMethod<dynamic>(
        methodName, data != null ? <Object>[data] : <Object>[]);
    streamController.sink.add(
        MethodCall(methodName, data != null ? <Object>[data] : <Object>[]));
  }
}

import 'dart:ffi';

import 'package:rust_flutter/bridge_generated.dart';
import 'package:test/test.dart';

void main() {

  test('main test', () async {
      final dylibPath = "target/debug/librust_flutter.dylib";
      final dylib = DynamicLibrary.open(dylibPath);
      final api = RustFlutterImpl(dylib);

      print('Executing rust_flutter.');

      {
      expect(await api.simpleAdder(a: 42, b: 100), 142);
      }
  });

}

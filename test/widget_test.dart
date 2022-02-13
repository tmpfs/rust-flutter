// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:ffi';

// import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:rust_flutter/bridge_generated.dart';
/*import 'package:test/test.dart';*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rust_flutter/main.dart';

void main() {

  test('main test', () async {
      final dylibPath = "target/x86_64-apple-darwin/debug/librust_flutter.dylib";
      final dylib = DynamicLibrary.open(dylibPath);
      final api = RustFlutterImpl(dylib);

      print('Executing rust_flutter.');

      {
      expect(await api.simpleAdder(a: 42, b: 100), 142);
      }
  });

/*
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
  */
}

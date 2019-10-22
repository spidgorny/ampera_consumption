// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter_ampera_consumption/NumberParser.dart';
import 'package:flutter_ampera_consumption/TextElement2.dart';
import 'package:flutter_ampera_consumption/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('Demo'), findsOneWidget);

    // Tap the 'Demo' icon and trigger a frame.
    await tester.tap(find.text('Demo'));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('e Used'), findsOneWidget);
  }, skip: true);

  test('Parse text', () async {
    List<TextElement2> textElements = [];
    String contents = await new File('test/tf-text.txt').readAsString();
    for (var line in contents.split('\n')) {
      var te = TextElement2(line.trim(), []);
      textElements.add(te);
    }
    print(textElements.map((te) => te.text));
    var np = NumberParser(textElements);
    np.parse();
    expect(np.eDist, equals(8.8));
    expect(np.eUsed, equals(2.4));
    expect(np.gDist, equals(0.0));
    expect(np.gUsed, equals(0.0));
  });
}

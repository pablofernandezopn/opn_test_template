// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child components in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opn_test_template/app/app.dart';

void main() {
  testWidgets('App starts at welcome screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      navigatorKey: GlobalKey<NavigatorState>(),
    ));

    // Wait for the app to render
    await tester.pumpAndSettle();

    // Verify that the welcome screen is shown
    expect(find.text('OPN Test'), findsOneWidget);
    expect(find.text('Consigue tu apto para la Policía Nacional'), findsOneWidget);

    // Verify that the action buttons are present
    expect(find.text('Empezar'), findsOneWidget);
    expect(find.text('Ya tengo cuenta'), findsOneWidget);
  });
}

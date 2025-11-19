import 'package:clue/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Displays login call-to-action', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Login()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Google 계정'), findsOneWidget);
  });
}

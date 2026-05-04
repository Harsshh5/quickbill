// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:quickbill/main.dart';

void main() {
  testWidgets('QuickBill app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // Don't use pumpAndSettle(): the app contains ongoing animations/tickers
    // (e.g. skeleton loaders), so settling may time out.
    await tester.pump();

    // Initial screen should show app title text.
    expect(find.text('QUICK BILL'), findsOneWidget);
    expect(find.text('Enter PIN'), findsOneWidget);
  });
}

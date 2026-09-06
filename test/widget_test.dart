// Smoke test: the app should boot to the splash screen without crashing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:billiard_customer/main.dart';

void main() {
  testWidgets('app boots to the splash screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const BilliardCustomerApp());
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
  });
}

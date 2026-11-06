import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_flutter_lab_external/screens/calculator_screen.dart';

void main() {
  testWidgets('Calculator Form shows validation errors when empty', (WidgetTester tester) async {
    // 1. Build the CalculatorScreen
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CalculatorScreen()),
      ),
    );

    // 2. Verify the screen loaded
    expect(find.text('Attendance Simulator'), findsOneWidget);

    // 3. Tap the Calculate button without entering any data
    await tester.tap(find.text('Calculate Result'));
    await tester.pumpAndSettle(); // Wait for animations/rebuilds

    // 4. Verify that the error messages appear (from AppValidators)
    expect(find.text('Attended is required'), findsOneWidget);
    expect(find.text('Total classes is required'), findsOneWidget);
  });
}
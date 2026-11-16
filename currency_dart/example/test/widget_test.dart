import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('currency searches normalize input and handle missing results',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Current currencies'), findsOneWidget);
    for (final query in [' usd ', ' United States DOLLAR ', 'unknown']) {
      await tester.enterText(find.byType(TextField), query);
      await tester.tap(find.byTooltip('Search currencies'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
          find.text(query == 'unknown'
              ? 'Currency not found'
              : 'United States dollar'),
          findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    }
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('small screen with keyboard keeps the list within the viewport',
      (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 180);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

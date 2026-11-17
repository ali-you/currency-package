import 'package:currency_flutter/currency_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repository = CurrencyRepository();

  Future<void> pumpPicker(WidgetTester tester,
          {Currency? value,
          bool historical = false,
          bool nonIso = true,
          CurrencyNameBuilder? nameBuilder,
          ValueChanged<Currency>? onChanged}) =>
      tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CurrencyPicker(
            value: value,
            historical: historical,
            nonIso: nonIso,
            nameBuilder: nameBuilder,
            onChanged: onChanged ?? (_) {},
          ),
        ),
      ));

  testWidgets('searches metadata and returns the selected currency',
      (tester) async {
    Currency? selected;
    await pumpPicker(tester, onChanged: (value) => selected = value);
    for (final query in [' usd ', 'United States']) {
      await tester.enterText(find.byType(TextField), query);
      await tester.pump();
      expect(find.byKey(const ValueKey('USD')), findsOneWidget);
    }
    await tester.enterText(find.byType(TextField), r'$');
    await tester.pump();
    expect(find.byKey(const ValueKey('ARS')), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'USD');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('USD')));
    expect(selected, repository.byCode('USD'));
  });

  testWidgets('filters historical and custom currencies, including on updates',
      (tester) async {
    await pumpPicker(tester, nonIso: false);
    await tester.enterText(find.byType(TextField), 'IRT');
    await tester.pump();
    expect(find.text('No currencies found'), findsOneWidget);
    await pumpPicker(tester);
    expect(find.byKey(const ValueKey('IRT')), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'BGN');
    await tester.pump();
    expect(find.text('No currencies found'), findsOneWidget);
    await pumpPicker(tester, historical: true);
    expect(find.byKey(const ValueKey('BGN')), findsOneWidget);
  });

  testWidgets('uses localized names for display and search and marks selection',
      (tester) async {
    await pumpPicker(tester,
        value: repository.byCode('USD'),
        nameBuilder: (currency) =>
            currency.isoCode == 'USD' ? 'دلار آمریکا' : currency.currencyName);
    await tester.enterText(find.byType(TextField), 'دلار');
    await tester.pump();
    expect(find.text('دلار آمریکا'), findsOneWidget);
    final tile = tester.widget<ListTile>(find.byKey(const ValueKey('USD')));
    expect(tile.selected, isTrue);
    expect(find.byIcon(Icons.check), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'no such currency');
    await tester.pump();
    expect(find.text('No currencies found'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();
    expect(find.text('No currencies found'), findsNothing);
  });

  testWidgets('dialog returns a selection and null on cancellation',
      (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 180);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    Currency? selected;
    var completed = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              selected = await showCurrencyPicker(context: context);
              completed = true;
            },
            child: const Text('Open picker'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'MRU');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('MRU')));
    await tester.pumpAndSettle();
    expect(selected, repository.byCode('MRU'));
    expect(completed, isTrue);
    completed = false;
    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
        of: find.byType(Dialog), matching: find.byType(TextButton)));
    await tester.pumpAndSettle();
    expect(selected, isNull);
    expect(completed, isTrue);
    expect(tester.takeException(), isNull);
  });
}

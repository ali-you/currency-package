import 'package:currency_flutter/currency_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'custom currency labels use the general code rather than null ISO',
      (tester) async {
    final toman = Currency().byCode('TOMAN')!;
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: CurrencyLabel(currency: toman),
    ));
    expect(find.text('🇮🇷 IRT — Iranian toman'), findsOneWidget);
  });
  test('public library exports the shared metadata API', () {
    expect(Currency().byIsoCode(' xcg ')!.status, CurrencyStatus.current);
    expect(Currency().byCurrencyName('missing'), isNull);
  });

  testWidgets('label displays currency and a representative flag',
      (tester) async {
    final currency = Currency().byIsoCode('USD')!;
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: CurrencyLabel(currency: currency),
    ));
    expect(find.text('${currency.flag} USD — United States dollar'),
        findsOneWidget);
    final text = tester.widget<Text>(find.byType(Text));
    expect(text.semanticsLabel, 'USD, United States dollar');
  });

  testWidgets('label supports omitted or unknown flags', (tester) async {
    for (final currency in [
      Currency().byIsoCode('USD')!,
      Currency().byIsoCode('ZWG')!
    ]) {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: CurrencyLabel(currency: currency, showFlag: false),
      ));
      expect(find.text('${currency.isoCode} — ${currency.currencyName}'),
          findsOneWidget);
    }
  });
}

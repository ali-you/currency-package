import 'package:currency_dart/currency_dart.dart';
import 'package:test/test.dart';

void main() {
  test('custom records cannot claim ISO identity or numeric identifiers', () {
    expect(() => CurrencyModel.fromJson({'code': 'TOMAN', 'status': 'current'}),
        throwsFormatException);
    expect(
        () => CurrencyModel.fromJson(
            {'code': 'TOMAN', 'isoCode': 'IRR', 'status': 'current'}),
        throwsFormatException);
    expect(
        () => CurrencyModel.fromJson(
            {'code': 'TOMAN', 'status': 'nonIso', 'numericCode': 364}),
        throwsFormatException);
  });
  test('minimal JSON uses the documented optional-field defaults', () {
    final currency = CurrencyModel.fromJson({'isoCode': 'USD'});
    expect(currency.currencyName, 'Not defined');
    expect(currency.numericCodeString, isNull);
    expect(currency.territories, isEmpty);
    expect(currency.status, CurrencyStatus.current);
  });

  test('JSON round trip preserves value equality and hash codes', () {
    for (final currency
        in Currency().getAllCurrencies(includeHistorical: true)) {
      final copy = CurrencyModel.fromJson(currency.toJson());
      expect(copy, currency);
      expect(copy.hashCode, currency.hashCode);
    }
    expect(Currency().byIsoCode('ALL')!.numericCodeString, '008');
  });

  test('invalid JSON reports the field rather than a dynamic cast failure', () {
    for (final entry in <String, Object?>{
      'isoCode': 'usd',
      'currencyName': 5,
      'numericCode': '840',
      'minorUnit': -1,
      'territories': ['USA', 2],
      'status': 'inactive',
      'aliases': 'invalid',
      'flag': true,
    }.entries) {
      expect(
        () =>
            CurrencyModel.fromJson({'isoCode': 'USD', entry.key: entry.value}),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains(entry.key),
        )),
      );
    }
    expect(() => CurrencyModel.fromJson({}), throwsFormatException);
  });

  test('territories are defensive copies and cannot mutate a currency', () {
    final input = ['UNITED STATES OF AMERICA (THE)'];
    final currency = CurrencyModel(isoCode: 'USD', territories: input);
    input.clear();
    expect(currency.territories, hasLength(1));
    expect(() => currency.territories.clear(), throwsUnsupportedError);
  });
}

import 'package:currency_dart/currency_dart.dart';
import 'package:test/test.dart';

void main() {
  test('isoCode is required in JSON for every status', () {
    for (final status in CurrencyStatus.values) {
      for (final fields in <Map<String, dynamic>>[
        {},
        {'isoCode': null},
        {'code': 'USD'},
      ]) {
        expect(
          () => Currency.fromJson({...fields, 'status': status.name}),
          throwsFormatException,
        );
      }
    }
    expect(
      () => Currency.fromJson(
          {'isoCode': 'IRT', 'status': 'nonIso', 'numericCode': 364}),
      throwsFormatException,
    );
  });
  test('minimal JSON uses the documented optional-field defaults', () {
    final currency = Currency.fromJson({'isoCode': 'USD'});
    expect(currency.currencyName, 'Not defined');
    expect(currency.numericCodeString, isNull);
    expect(currency.countryIsoCode, isNull);
    expect(currency.countryIsoCodes, isEmpty);
    expect(currency.territories, isEmpty);
    expect(currency.status, CurrencyStatus.current);
  });

  test('JSON round trip preserves value equality and hash codes', () {
    for (final currency
        in CurrencyRepository().getAllCurrencies(includeHistorical: true)) {
      final copy = Currency.fromJson(currency.toJson());
      expect(copy, currency);
      expect(copy.hashCode, currency.hashCode);
    }
    expect(CurrencyRepository().byIsoCode('ALL')!.numericCodeString, '008');
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
      'countryIsoCode': 'USA',
      'countryIsoCodes': ['US', 'usa'],
    }.entries) {
      expect(
        () => Currency.fromJson({'isoCode': 'USD', entry.key: entry.value}),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains(entry.key),
        )),
      );
    }
    expect(() => Currency.fromJson({}), throwsFormatException);
  });

  test('representative country codes survive JSON and affect equality', () {
    final usd = CurrencyRepository().byIsoCode('USD')!;
    expect(usd.countryIsoCode, 'US');
    expect(CurrencyRepository().byIsoCode('EUR')!.countryIsoCode, isNull);
    final changed =
        Currency.fromJson({...usd.toJson(), 'countryIsoCode': 'CA'});
    expect(changed.countryIsoCode, 'CA');
    expect(changed, isNot(usd));
    expect(Currency.fromJson(changed.toJson()), changed);
  });

  test('country codes include shared territories and are immutable values', () {
    expect(CurrencyRepository().byIsoCode('USD')!.countryIsoCodes,
        containsAll(['US', 'EC']));
    expect(CurrencyRepository().byIsoCode('EUR')!.countryIsoCodes,
        containsAll(['DE', 'FR']));
    final input = ['US'];
    final model = Currency(isoCode: 'USD', countryIsoCodes: input);
    input.clear();
    expect(model.countryIsoCodes, ['US']);
    expect(() => model.countryIsoCodes.clear(), throwsUnsupportedError);
    final copy = Currency.fromJson(model.toJson());
    expect(copy, model);
    expect(copy.hashCode, model.hashCode);
    expect(Currency(isoCode: 'USD', countryIsoCodes: ['CA']), isNot(model));
    for (final invalid in <Object>[
      'US',
      [1],
      ['usa'],
      ['USA']
    ]) {
      expect(
          () =>
              Currency.fromJson({'isoCode': 'USD', 'countryIsoCodes': invalid}),
          throwsFormatException);
    }
  });

  test('territories are defensive copies and cannot mutate a currency', () {
    final input = ['UNITED STATES OF AMERICA (THE)'];
    final currency = Currency(isoCode: 'USD', territories: input);
    input.clear();
    expect(currency.territories, hasLength(1));
    expect(() => currency.territories.clear(), throwsUnsupportedError);
  });
}

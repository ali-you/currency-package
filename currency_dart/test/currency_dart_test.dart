import 'dart:convert';
import 'dart:io';

import 'package:currency_dart/currency_dart.dart';
import 'package:currency_dart/src/currency_repo.dart';
import 'package:test/test.dart';

void main() {
  final currency = Currency();

  test('code lookups normalize input and return null for missing codes', () {
    expect(currency.byIsoCode(' usd ')!.isoCode, 'USD');
    expect(currency.byIsoCode('UNKNOWN'), isNull);
    expect(currency.byIsoCode(''), isNull);
  });

  test('name lookups normalize input and handle missing and ambiguous names',
      () {
    expect(currency.byCurrencyName(' United States DOLLAR ')!.isoCode, 'USD');
    expect(currency.byCurrencyName('unknown'), isNull);
    expect(currency.byCurrencyName(''), isNull);
    // Both VED and VES have this official display name.
    expect(currency.byCurrencyName('Bolívar Soberano'), isNull);
  });

  test('historical codes require opt-in in all lookup methods', () {
    for (final code in ['ANG', 'BGN', 'HRK', 'SLL', 'STD', 'VEF']) {
      expect(currency.byIsoCode(code), isNull);
      final historical = currency.byIsoCode(code, includeHistorical: true)!;
      expect(historical.status, CurrencyStatus.historical);
      expect(historical.withdrawalDate, isNotEmpty);
      expect(currency.byCurrencyName(historical.currencyName), isNull);
      expect(
          currency.byCurrencyName(
            historical.currencyName,
            includeHistorical: true,
          ),
          historical);
    }
    // BYR and its current replacement BYN share the same display name.
    expect(currency.byIsoCode('BYR'), isNull);
    expect(currency.byCurrencyName('Belarusian ruble')!.isoCode, 'BYN');
    expect(currency.byCurrencyName('Belarusian ruble', includeHistorical: true),
        isNull);
  });

  test('current replacements and authoritative metadata are available', () {
    for (final code in [
      'BYN',
      'MRU',
      'SLE',
      'STN',
      'SVC',
      'UYW',
      'VED',
      'VES',
      'XAD',
      'XCG',
      'XSU',
      'XUA',
      'ZWG',
    ]) {
      expect(currency.byIsoCode(code), isNotNull, reason: code);
    }
    expect(currency.byIsoCode('ZWG')!.numericCode, 924);
    expect(currency.byIsoCode('XCG')!.numericCode, 532);
    expect(currency.byIsoCode('XPD')!.numericCode, 964);
    expect(currency.byIsoCode('XPT')!.numericCode, 962);
    expect(currency.byIsoCode('XTS')!.numericCode, 963);
    expect(currency.byIsoCode('XXX')!.numericCode, 999);
    expect(currency.byIsoCode('JPY')!.minorUnit, 0);
    expect(currency.byIsoCode('KWD')!.minorUnit, 3);
    expect(currency.byIsoCode('EUR')!.territories, contains('BULGARIA'));
  });

  test('filters separate currency, fund, metal and special-purpose codes', () {
    expect(currency.byIsoCode('XAU')!.category, CurrencyCategory.preciousMetal);
    expect(currency.byIsoCode('XDR')!.category, CurrencyCategory.fund);
    expect(currency.byIsoCode('XXX')!.category, CurrencyCategory.special);
    final currencies =
        currency.getAllCurrencies(category: CurrencyCategory.currency);
    expect(currencies, isNotEmpty);
    expect(currencies.every((c) => c.category == CurrencyCategory.currency),
        isTrue);
  });

  test('public lists and nested repository data cannot be mutated', () {
    expect(() => currency.getAllCurrencies().clear(), throwsUnsupportedError);
    expect(() => CurrencyRepo.currencies.clear(), throwsUnsupportedError);
    expect(() => CurrencyRepo.currencies['USD']!['numericCode'] = 1,
        throwsUnsupportedError);
    expect(
        () => (CurrencyRepo.currencies['USD']!['territories'] as List).clear(),
        throwsUnsupportedError);
  });

  test('all generated records match canonical JSON and provenance counts', () {
    final source =
        jsonDecode(File('../currency.json').readAsStringSync()) as Map;
    final metadata = jsonDecode(
      File('../currency.metadata.json').readAsStringSync(),
    ) as Map;
    final all = currency.getAllCurrencies(includeHistorical: true);
    expect(all.length, source.length);
    expect(currency.getAllCurrencies().length, metadata['currentCount']);
    expect(all.length - currency.getAllCurrencies().length,
        metadata['historicalCount']);
    expect(all.map((c) => c.isoCode).toSet().length, all.length);
    for (final entry in source.entries) {
      final actual =
          currency.byIsoCode(entry.key as String, includeHistorical: true)!;
      expect(actual.toJson(), entry.value, reason: entry.key as String);
      expect(actual.isoCode, entry.key);
      if (actual.status == CurrencyStatus.current) {
        expect(actual.numericCode, isNotNull);
      }
    }
  },
      // Canonical input is a repository-level development artifact, not part of
      // the published core package. Unit tests still run outside a checkout.
      skip: !File('../currency.json').existsSync());
}

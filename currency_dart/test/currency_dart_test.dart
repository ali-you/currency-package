import 'dart:convert';
import 'dart:io';

import 'package:currency_dart/currency_dart.dart';
import 'package:currency_dart/src/currency_repo.dart';
import 'package:test/test.dart';

void main() {
  final currency = CurrencyRepository();

  test('history and non-ISO flags independently control lists and searches',
      () {
    for (final historical in [false, true]) {
      for (final nonIso in [false, true]) {
        final results =
            currency.getAllCurrencies(historical: historical, nonIso: nonIso);
        expect(results.length, 155 + (historical ? 11 : 0) + (nonIso ? 9 : 0));
        expect(results.any((c) => c.isoCode == 'BGN'), historical);
        expect(results.any((c) => c.isoCode == 'IRT'), nonIso);
        expect(results.any((c) => c.isoCode == 'USD'), isTrue);
        expect(
            currency.byCode('IRT', historical: historical, nonIso: nonIso) !=
                null,
            nonIso);
        expect(
            currency.byIsoCode('BGN', historical: historical, nonIso: nonIso) !=
                null,
            historical);
        expect(
            currency.byCurrencyName('Iranian toman',
                    historical: historical, nonIso: nonIso) !=
                null,
            nonIso);
        expect(() => results.clear(), throwsUnsupportedError);
      }
    }
    expect(currency.getAllCurrencies(includeHistorical: true),
        currency.getAllCurrencies(historical: true));
  });

  test('custom entries use explicit status and never impersonate ISO codes',
      () {
    final statuses = {
      'TOMAN': CurrencyStatus.nonIso,
      'SOMALILAND_SHILLING': CurrencyStatus.nonIso,
      'TRANSNISTRIAN_RUBLE': CurrencyStatus.nonIso,
      'MANX_POUND': CurrencyStatus.nonIso,
      'JERSEY_POUND': CurrencyStatus.nonIso,
      'GUERNSEY_POUND': CurrencyStatus.nonIso,
      'FAROESE_KRONA': CurrencyStatus.nonIso,
      'EUSKO': CurrencyStatus.nonIso,
      'CHIEMGAUER': CurrencyStatus.nonIso,
    };
    for (final entry in statuses.entries) {
      final model = currency.byCode(' ${entry.key.toLowerCase()} ')!;
      expect(model.status, entry.value);
      expect(model.isoCode, matches(RegExp(r"^[A-Z]{3}$")));
      expect(currency.byIsoCode(model.isoCode), model);
      expect(currency.byCode(model.isoCode), model);
      expect(model.numericCode, isNull);
      expect(currency.byIsoCode(entry.key), isNull);
      expect(currency.byIsoCode(model.isoCode), model);
      expect(model.flag, isNotNull);
      expect(model.currencySymbol, isNotNull);
      expect(currency.byCurrencyName(model.currencyName), model);
    }
    expect(currency.byCode('USD'), currency.byIsoCode('USD'));
  });

  test('corrected display data preserves legacy and official-name searches',
      () {
    final pen = currency.byIsoCode('PEN')!;
    expect(pen.currencyName, 'Peruvian sol');
    expect(pen.currencySymbol, 'S/');
    expect(pen.officialName, 'Sol');
    expect(currency.byCurrencyName(' Peruvian NUEVO sol '), pen);
    expect(currency.byCurrencyName('Sol'), pen);
    expect(currency.byIsoCode('XCG')!.currencySymbol, 'Cg');
    expect(
        currency
            .getAllCurrencies(includeHistorical: true)
            .any((c) => c.fractionalUnit == 'None'),
        isFalse);
    expect(() => pen.aliases.clear(), throwsUnsupportedError);
  });

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
      'VED',
      'VES',
      'XCG',
      'ZWG',
    ]) {
      expect(currency.byIsoCode(code), isNotNull, reason: code);
    }
    expect(currency.byIsoCode('ZWG')!.numericCode, 924);
    expect(currency.byIsoCode('XCG')!.numericCode, 532);
    expect(currency.byIsoCode('JPY')!.minorUnit, 0);
    expect(currency.byIsoCode('KWD')!.minorUnit, 3);
    expect(currency.byIsoCode('EUR')!.territories, contains('BULGARIA'));
  });

  test('current currencies have symbols and representative flags', () {
    for (final model in currency.getAllCurrencies(nonIso: false)) {
      expect(model.currencySymbol, isNotEmpty, reason: model.isoCode);
      expect(model.flag, isNotEmpty, reason: model.isoCode);
    }
    final corrected = {
      'BYN': ['Br', '🇧🇾', 'BY'],
      'MRU': ['UM', '🇲🇷', 'MR'],
      'SLE': ['NLe', '🇸🇱', 'SL'],
      'STN': ['Db', '🇸🇹', 'ST'],
      'SVC': ['₡', '🇸🇻', 'SV'],
      'VED': ['Bs.', '🇻🇪', 'VE'],
      'VES': ['Bs.', '🇻🇪', 'VE'],
      'XCG': ['Cg', '🇨🇼', 'CW'],
      'ZWG': ['ZiG', '🇿🇼', 'ZW'],
    };
    for (final entry in corrected.entries) {
      final model = currency.byIsoCode(entry.key)!;
      expect(model.currencySymbol, entry.value[0], reason: entry.key);
      expect(model.flag, entry.value[1], reason: entry.key);
      expect(model.countryIsoCode, entry.value[2], reason: entry.key);
    }
    expect(currency.byIsoCode('XCG')!.countryIsoCodes, ['CW', 'SX']);
  });

  test('only currencies are exposed, including shared X-prefixed currencies',
      () {
    for (final code in [
      'XAU',
      'XAG',
      'XPD',
      'XPT',
      'XDR',
      'XTS',
      'XXX',
      'USN',
      'USS',
      'XFU',
      'UYW'
    ]) {
      expect(currency.byIsoCode(code, includeHistorical: true), isNull);
    }
    for (final code in ['EUR', 'XAF', 'XOF', 'XCD', 'XPF', 'XCG']) {
      expect(currency.byIsoCode(code), isNotNull);
    }
    expect(currency.getAllCurrencies(), hasLength(164));
    expect(currency.getAllCurrencies(includeHistorical: true), hasLength(175));
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
        jsonDecode(File('../data/currencies/currency.json').readAsStringSync())
            as Map;
    final metadata = jsonDecode(
      File('../data/currencies/currency.metadata.json').readAsStringSync(),
    ) as Map;
    final all = currency.getAllCurrencies(includeHistorical: true);
    expect(all.length, source.length);
    expect(currency.getAllCurrencies().length,
        metadata['currentCount'] + metadata['customCount']);
    expect(all.length - currency.getAllCurrencies().length,
        metadata['historicalCount']);
    expect(all.map((c) => c.isoCode).toSet().length, all.length);
    for (final entry in source.entries) {
      final actual =
          currency.byCode(entry.key as String, includeHistorical: true)!;
      expect(actual.toJson(), entry.value, reason: entry.key as String);
      expect(actual.isoCode, entry.key);
      if (actual.status == CurrencyStatus.current) {
        expect(actual.numericCode, isNotNull);
      }
    }
  },
      // Canonical input is a repository-level development artifact, not part of
      // the published core package. Unit tests still run outside a checkout.
      skip: !File('../data/currencies/currency.json').existsSync());
}

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:currency_localization/currency_localization.dart';
import 'package:test/test.dart';
import 'package:currency_localization/src/currency_names.dart';

void main() {
  const names = CurrencyLocalization();
  final hasRepository = File('../tool/data/cldr/49.0.0/en.json').existsSync();

  test('generated translations exactly match pinned CLDR and provenance', () {
    final provenance =
        jsonDecode(File('data_provenance.json').readAsStringSync()) as Map;
    expect(provenance['localeCount'], names.supportedLocales.length);
    final files = Directory('../tool/data/cldr/49.0.0')
        .listSync()
        .whereType<File>()
        .map((file) => file.uri.pathSegments.last)
        .where((name) => name.endsWith('.json') && name != 'parentLocales.json')
        .map((name) => name.substring(0, name.length - 5).toLowerCase())
        .toSet();
    expect(names.supportedLocales, files);
    final parents =
        File('../tool/data/cldr/49.0.0/parentLocales.json').readAsBytesSync();
    expect(
        sha256.convert(parents).toString(), provenance['parentLocalesSha256']);
    for (final source in provenance['sources'] as List) {
      final locale = source['locale'] as String;
      final bytes =
          File('../tool/data/cldr/49.0.0/$locale.json').readAsBytesSync();
      expect(sha256.convert(bytes).toString(), source['sha256']);
      final raw = jsonDecode(utf8.decode(bytes)) as Map;
      final rows = raw['main'][locale]['numbers']['currencies'] as Map;
      var count = 0;
      final missing = <String>[];
      for (final code in names.supportedCurrencyCodes) {
        final value = (rows[code] as Map?)?['displayName'];
        final expected = value == code ? null : value;
        expect(localizedCurrencyNames[locale.toLowerCase()]?[code], expected,
            reason: '$locale/$code');
        if (expected == null) {
          missing.add(code);
        } else {
          count++;
        }
      }
      expect(count, source['translatedCount']);
      expect(missing, source['missingCodes']);
    }
    final canonical =
        jsonDecode(File('../currency.json').readAsStringSync()) as Map;
    expect(names.supportedCurrencyCodes, canonical.keys.toSet());
    expect(names.supportedCurrencyCodes.length, provenance['currencyCount']);
  }, skip: !hasRepository);

  test('bundled Unicode license matches the recorded source hash', () {
    final provenance =
        jsonDecode(File('data_provenance.json').readAsStringSync()) as Map;
    final bytes = File('third_party/UNICODE_LICENSE.txt').readAsBytesSync();
    expect(sha256.convert(bytes).toString(), provenance['licenseSha256']);
    expect(utf8.decode(bytes), contains('UNICODE LICENSE V3'));
  });
}

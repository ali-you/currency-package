// Run from currency_localization: dart run tool/audit.dart [--json]
import 'dart:convert';
import 'dart:io';

import 'package:currency_localization/currency_localization.dart';

/// Reports native translation coverage after regional/script inheritance.
/// Unlike name(), lookup() does not hide gaps behind English fallback.
void main(List<String> arguments) {
  const names = CurrencyLocalization();
  final root = File.fromUri(Platform.script).parent.parent.parent;
  final currencies = jsonDecode(
    File('${root.path}/data/currencies/currency.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final nonIso = currencies.entries
      .where((entry) => entry.value['status'] == 'nonIso')
      .map((entry) => entry.key)
      .toSet();
  final locales = names.supportedLocales.toList()..sort();
  final codes = names.supportedCurrencyCodes.toList()..sort();
  final rows = <Map<String, Object>>[];
  var complete = 0;
  var nonIsoComplete = 0;
  var missingCount = 0;
  for (final locale in locales) {
    final missing = codes
        .where((code) => names.lookup(code, locale: locale) == null)
        .toList();
    final missingNonIso = missing.where(nonIso.contains).toList();
    if (missing.isEmpty) complete++;
    if (missingNonIso.isEmpty) nonIsoComplete++;
    missingCount += missing.length;
    rows.add({
      'locale': locale,
      'nativeNameCount': codes.length - missing.length,
      'missingNativeCodes': missing,
      'missingNonIsoCodes': missingNonIso,
    });
  }
  final report = {
    'localeCount': locales.length,
    'currencyCount': codes.length,
    'nonIsoCurrencyCount': nonIso.length,
    'completeNativeLocaleCount': complete,
    'completeNonIsoLocaleCount': nonIsoComplete,
    'missingNativeNameCount': missingCount,
    'locales': rows,
  };
  if (arguments.contains('--json')) {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(report));
  } else {
    stdout.writeln('${locales.length} locales, ${codes.length} currencies '
        '(${nonIso.length} non-ISO).');
    stdout.writeln('Complete native coverage: $complete locales.');
    stdout.writeln('Complete non-ISO coverage: $nonIsoComplete locales.');
    stdout.writeln('Names requiring fallback: $missingCount.');
    stdout.writeln('Use --json for missing codes by locale.');
  }
}

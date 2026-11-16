# currency_localization

Offline currency display names for **all 657 locale datasets in CLDR 49**, including language, script and regional variants, generated from Unicode CLDR 49. Pure Dart, with no Flutter requirement,
runtime dependencies, network requests or asset initialization.

```yaml
dependencies:
  currency_localization: ^0.2.0
```

```dart
import 'package:currency_localization/currency_localization.dart';

const names = CurrencyLocalization();

names.name('USD', locale: 'fa'); // دلار آمریکا
names.name('EUR', locale: 'ar'); // يورو
names.name(' usd ', locale: 'FA_ir'); // دلار آمریکا
names.name('USD', locale: 'de'); // US-Dollar
names.name('ZZZ', locale: 'fa'); // ZZZ (unknown code)
names.name('XAD', locale: 'fa'); // XAD (no bundled CLDR translation)
```

## Use with the other packages

Map by **ISO code**, rather than translating the English `currencyName` string:

```dart
// With Currency/ CurrencyModel from currency_dart or currency_flutter:
final usd = Currency().byIsoCode('USD')!;
final localizedName = const CurrencyLocalization().name(usd.isoCode, locale: 'fa');
```

`currency_dart` and `currency_flutter` are optional consumers; this package does
not depend on them and does not modify `CurrencyModel.currencyName`.

In Flutter, pass the application's locale as a string:

```dart
final locale = Localizations.localeOf(context).toLanguageTag();
final label = const CurrencyLocalization().name(currency.isoCode, locale: locale);
```

The app supplies `Localizations` through Flutter; this package itself imports no
Flutter libraries. Rendering direction and fonts remain the application's job.

## Fallback and coverage

`name` searches the requested locale, its CLDR parent chain, the configured
`fallbackLocale` and its parents, English, then the normalized code. Regional
and script-specific names are preserved. Explicit CLDR parents take precedence
over truncation, including `root` boundaries that prevent falling into the wrong
script. Unknown tags use progressive truncation. Locale tags ignore case, accept
`_` or `-`, and ignore extension/private-use suffixes. This does not implement
language negotiation or canonicalization of deprecated locale aliases.

```dart
const names = CurrencyLocalization(fallbackLocale: 'ar');
names.name('USD', locale: 'zz'); // دولار أمريكي
names.lookup('USD', locale: 'zz'); // null: no configured or English fallback
names.supportsLocale('fa_IR'); // true (base fa is bundled)
names.supportsLocale('zz'); // false, even though name() can return English
names.supportedLocales; // immutable set of 657 normalized lowercase locale tags
names.supportedCurrencyCodes; // immutable set of 191 snapshot codes
names.names(['USD', 'EUR'], locale: 'fa'); // immutable ISO-code → name map
```

Codes are trimmed and uppercased. Empty input returns an empty string; unknown
input returns the normalized input. Bulk lookup deduplicates normalized codes.
`lookup` searches the requested locale and parents only and returns null when a
translation is absent. `supportsLocale` reports language dataset availability,
not complete translation coverage for every code.

The 191 codes match the repository currency snapshot: 178 current codes and
13 selected historical codes. Historical names can include dates to distinguish
them. They remain historical even though this package can display their names.

All locales distributed in the pinned `cldr-numbers-full` package are bundled.
This covers CLDR languages, not every language spoken worldwide. Translation
coverage varies by locale and currency; missing names use the documented fallback
rather than fabricated translations.

`data_provenance.json` lists source URLs, SHA-256 hashes and every missing code.
Names are the CLDR `displayName` values for labels/pickers. This release does
not choose grammatical plural forms, translate symbols, format amounts, or
provide exchange rates. All lookups work offline.

## Data generation and maintenance

Unmodified CLDR JSON snapshots live in the repository under
`tool/data/cldr/49.0.0/<locale>.json`. Runtime code contains generated const
maps and does not read those files. To check a repository checkout:

```sh
cd currency_localization
dart pub get --no-example
dart run tool/generate.dart --check
dart analyze --fatal-infos
dart test
dart run example/currency_localization_example.dart
```

The generator discovers every currency snapshot in the version directory. To
update CLDR, download the pinned `cldr-numbers-full` npm archive, extract every
`main/<locale>/currencies.json` to that directory, and also download matching
`cldr-core/supplemental/parentLocales.json` and the Unicode license. Regenerate
with `dart run tool/generate.dart` and review locale coverage and provenance.
CI checks the generated data, source hashes, analysis, formatting and tests.

## License

Code is MIT licensed. Translation data is from
[Unicode CLDR](https://cldr.unicode.org/) and is distributed under the Unicode
License V3; its unmodified notice is included in
`third_party/UNICODE_LICENSE.txt`. Preserve both notices on redistribution.

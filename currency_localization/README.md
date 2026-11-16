# currency_localization

Offline currency display names for **English (`en`), Persian (`fa`) and Arabic
(`ar`)**, generated from Unicode CLDR 49. Pure Dart, with no Flutter requirement,
runtime dependencies, network requests or asset initialization.

```yaml
dependencies:
  currency_localization: ^0.1.0
```

```dart
import 'package:currency_localization/currency_localization.dart';

const names = CurrencyLocalization();

names.name('USD', locale: 'fa'); // دلار آمریکا
names.name('EUR', locale: 'ar'); // يورو
names.name(' usd ', locale: 'FA_ir'); // دلار آمریکا
names.name('USD', locale: 'de'); // US Dollar (English fallback)
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

`name` searches the requested locale, successively shorter parent tags, the
configured `fallbackLocale` and its parents, English, then the normalized code.
For example, `fa-Arab-IR → fa-Arab → fa → en → ISO code`. With only the three
base datasets bundled, regional variants use the base-language translation;
this is simple tag fallback, not full CLDR locale inheritance or language matching.
Locale tags ignore case, accept `_` or `-`, and ignore extension/private-use
suffixes. Unrecognized or malformed input uses the same fallback policy.

```dart
const names = CurrencyLocalization(fallbackLocale: 'ar');
names.name('USD', locale: 'de'); // دولار أمريكي
names.lookup('USD', locale: 'de'); // null: no configured or English fallback
names.supportsLocale('fa_IR'); // true (base fa is bundled)
names.supportsLocale('de'); // false, even though name() can return English
names.supportedLocales; // immutable set: ar, en, fa
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

| Locale | Direct CLDR names | Missing before fallback |
|---|---:|---:|
| English | 190 | 1 |
| Persian | 172 | 19 |
| Arabic | 180 | 11 |

`data_provenance.json` lists source URLs, SHA-256 hashes and every missing code.
Names are the CLDR `displayName` values for labels/pickers. This release does
not choose grammatical plural forms, translate symbols, format amounts, or
provide exchange rates. All lookups work offline.

## Data generation and maintenance

Unmodified CLDR JSON snapshots live in the repository under
`tool/data/cldr/49.0.0/{ar,en,fa}.json`. Runtime code contains generated const
maps and does not read those files. To check a repository checkout:

```sh
cd currency_localization
dart pub get --no-example
dart run tool/generate.dart --check
dart analyze --fatal-infos
dart test
dart run example/currency_localization_example.dart
```

To add a language, download its `currencies.json` from the same pinned CLDR
release into that source directory, add the locale to `tool/generate.dart`,
regenerate with `dart run tool/generate.dart`, and review translations, coverage,
provenance, tests and documentation. The generator takes supported codes from
the root `currency.json`. To update CLDR, change the pinned version, download
all source files and the matching Unicode license, then regenerate and review.
CI checks the generated data, source hashes, analysis, formatting and tests.

## License

Code is MIT licensed. Translation data is from
[Unicode CLDR](https://cldr.unicode.org/) and is distributed under the Unicode
License V3; its unmodified notice is included in
`third_party/UNICODE_LICENSE.txt`. Preserve both notices on redistribution.

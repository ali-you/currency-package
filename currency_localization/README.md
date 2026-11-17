# currency_localization

Offline currency names for 657 language, script and regional locales.
Pure Dart with no runtime dependencies, Flutter requirement or network access.

```dart
import 'package:currency_localization/currency_localization.dart';

const names = CurrencyLocalization();
names.name('USD', locale: 'fa'); // دلار آمریکا
names.name('USD', locale: 'de'); // US-Dollar
names.name('USD', locale: 'ja'); // 米ドル
names.name(' usd ', locale: 'FA_ir'); // دلار آمریکا
```

## Data layout

Project translation files live directly in `data/localizations/<locale>.json`:

```json
{
  "EUR": "Euro",
  "USD": "US Dollar"
}
```

There is no external data-version directory or upstream-specific import process.
Edit translations directly in these maps. Missing names are omitted and use
fallback. Parent-locale overrides live separately in `data/locale_parents.json`.
The generated `data_coverage.json` records file checksums and missing codes.

From the package directory after editing data:

```sh
dart pub get --no-example
dart run tool/generate.dart
dart run tool/generate.dart --check
dart analyze --fatal-infos
dart test
```

To add a locale, add its JSON file and regenerate. Runtime uses generated const
maps and performs no file reads. CI validates generated output against project
data. The maps cover 175 codes from root `data/currencies/currency.json`: 155 current, 11 historical and 9 custom entries. Translation coverage varies; unsupported or missing
names fall back rather than being invented.

## Lookup and fallback

Names are keyed by the general currency code. To use a Currency from currency_dart or
currency_flutter, call `names.name(currency.isoCode, locale: 'fa')`.
The existing model's `currencyName` stays unchanged.

Resolution is requested locale, its parents, configured fallback and its parents,
English, then the trimmed uppercase code. Parent overrides take precedence over
truncation and preserve script boundaries. Tags ignore case, accept underscores
or hyphens, and ignore extension/private-use suffixes. This is tag fallback,
not language negotiation or canonicalization of deprecated aliases.

```dart
const names = CurrencyLocalization(fallbackLocale: 'ar');
names.name('USD', locale: 'zz'); // دولار أمريكي
names.lookup('USD', locale: 'zz'); // null (no fallback locale applied)
names.supportsLocale('fa_IR'); // true
names.supportedLocales; // immutable lowercase locale tags
names.supportedCurrencyCodes; // immutable currency code set
names.names(['USD', 'EUR'], locale: 'fa'); // immutable normalized code/name map
```

Unknown input returns its trimmed uppercase form; empty input returns empty.
`lookup` searches the requested locale and parents only. `supportsLocale`
describes dataset availability, not complete currency coverage. Bulk lookup
collapses duplicate normalized codes. Historical labels do not change a
currency's historical status.

In Flutter, use `Localizations.localeOf(context).toLanguageTag()` as the locale.
Directionality and fonts are handled by the app. Names are display labels;
this package does not format amounts, select grammatical plurals, translate
symbols or provide exchange rates.

## Resources and licensing

[Unicode CLDR](https://cldr.unicode.org/) was the initial resource for currency
names and parent-locale mappings. Project maps are now maintained independently;
the implementation has no CLDR-specific API, release version or import dependency.
Code is MIT licensed. Derived translation data retains the Unicode License V3
notice in `third_party/UNICODE_LICENSE.txt`; preserve both notices when redistributing.

## Migration to 0.3.0

The source-specific `cldrVersion` getter has been removed. Read the package
version for release identification. Generated coverage is now `data_coverage.json`.

## Custom identifiers

All nine custom entries have status `nonIso`. Their `isoCode` field contains a
three-letter project code, such as `IRT` for toman; these are not registered
ISO 4217 codes. Check status before treating any code as an ISO identifier.
`byIsoCode('IRT')` and `byCode('IRT')` resolve the same record as
`byCode('TOMAN')`. JSON keys match isoCode. Use the required isoCode field to read the identifier.

Localization accepts either form: `names.name('IRT', locale: 'fa')` displays
`تومان ایران`. `supportedCurrencyCodes` lists the short identifiers used in the JSON files;
descriptive identifiers are accepted as backward-compatible aliases. Numeric ISO codes remain null for nonIso.
English, Persian and Arabic names are provided; other locales use fallback.
Historical entries remain opt-in. Conversion rules are not supplied.

Currency JSON stores only `isoCode`; each record key has the same value.
The Dart model requires a non-null `isoCode`. Project
short codes remain marked `nonIso`. Localizations use the same short keys.

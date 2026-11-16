# World Currency Information

Offline metadata for 155 current and 11 selected historical currencies.
Funds, accounting units, metals and special-purpose codes are excluded. Shared
currencies such as EUR, XAF, XOF and XCD are included.

- `currency_dart`: pure Dart lookups and immutable metadata, with no Flutter dependency.
- `currency_flutter`: the same public API plus the `CurrencyLabel` widget.
- `currency_localization`: offline currency names for 657 locales,
  keyed by ISO code, with locale fallback and no Flutter dependency.
- `currency.json`: canonical metadata used to generate the Dart repository.
- `currency.metadata.json`: source URLs, publication dates, hashes and coverage.
- `currency.annotations.json`: curated display values and field-level verification.
- `currency.schema.json`: external JSON Schema for data and annotation validation.
- `data/localizations/`: compact per-locale currency-name maps and source provenance.

## Usage

```dart
import 'package:currency_dart/currency_dart.dart';

final currencies = Currency();
final usd = currencies.byIsoCode(' usd '); // USD
final found = currencies.byCurrencyName(' United States DOLLAR ');
final missing = currencies.byCurrencyName('unknown'); // null
final current = currencies.getAllCurrencies();
final historical = currencies.byIsoCode('BGN', includeHistorical: true);
```

Lookups trim surrounding whitespace and ignore case. Display names, official names and aliases match exactly after normalization;
ambiguous names return null. ISO codes are the reliable identifiers.
Historical codes require `includeHistorical: true` in lookups and lists.
Returned lists and territory lists are immutable.

## Data fields and provenance

For localized labels, keep currency metadata unchanged and resolve by ISO code:

```dart
import 'package:currency_localization/currency_localization.dart';

const names = CurrencyLocalization();
final label = names.name('USD', locale: 'fa_IR'); // دلار آمریکا
```

See [currency_localization](currency_localization/README.md) for coverage,
fallback behavior and generation instructions. Its project-maintained translation maps live directly in `data/localizations`.
Unicode CLDR is documented as an initial resource; its data license is preserved.

The [SIX ISO 4217 registers](https://www.six-group.com/en/products-services/financial-information/market-reference-data/data-standards.html)
provide ISO codes, numeric codes, entity names, minor-unit exponents and historical
withdrawal dates. The unmodified source snapshots are in `data/sources/currencies`; their
publication dates differ and are recorded separately. The historical subset is not a complete historical archive.

| Field | Meaning |
|---|---|
| `isoCode` | Three-letter ISO code |
| `currencyName` | Curated display name |
| `officialName` | Name from the ISO register |
| `aliases` | Previous display labels retained for compatible searches |
| `numericCode` | Integer ISO number; use `numericCodeString` for padded values such as `008` |
| `territories` | Structured entity names from ISO; names can contain commas |
| `territory` | Joined display label for compatibility |
| `minorUnit` | Decimal exponent, for example JPY 0, USD 2, KWD 3 |
| `status` | `current` or `historical` |
| `withdrawalDate` | Source withdrawal date, preserving year/month precision |
| `currencySymbol`, `fractionalUnit`, `flag` | Optional supplemental display annotations |

Null means unknown or not applicable. Symbols, subdivision names and representative
flags are not verified by ISO and are incomplete. A flag does not describe every
territory using a currency. `fractionalUnit` is a name, not a formatting precision.
This package provides no exchange rates, money arithmetic or price formatting.

## Development

With a Dart SDK:

```sh
cd currency_dart
dart pub get --no-example
dart analyze
dart test
dart run tool/generate.dart --check
```

The `--no-example` flag keeps core development independent of Flutter. For the
Flutter package or either example, run `flutter pub get`, `flutter analyze` and
`flutter test` in its directory. Checked-in `pubspec_overrides.yaml` files resolve
the sibling Dart package locally; the release manifest uses a hosted dependency.
Publish `currency_dart` 0.2.0 before publishing `currency_flutter` 0.2.0. Published
artifacts exclude dependency overrides.

Update the pinned SIX XML snapshots, run `python scripts/refresh_data.py` from the
repository root, then run `dart run tool/generate.dart` from `currency_dart`.
Review data changes and run the tests. Both scripts accept `--check`; CI validates
register/data consistency, generated output, analysis, formatting and tests.
See `data/sources/currencies/README.md` for the source and annotation policy.

## License and attribution

Package code is distributed under the existing [MIT License](LICENSE). Existing
Wen Du and CFUG Team notices have been preserved; their inclusion does not claim
those authors verified the currency data. SIX is the upstream register source.
Legacy annotations remain marked `legacyUnverified`. Verified corrections have
field-level source URLs and dates in `currency.annotations.json`. Null values are
retained where reliable annotations are unavailable.

Validate data edits with `python -m pip install -r scripts/requirements.txt`,
`python scripts/validate_currency.py` and `python -m unittest discover -s scripts -p
'test_*.py'`. Edit supplemental values in `currency.annotations.json`, then
refresh the JSON and generated Dart as described above. ISO current status means
membership in the current register, not a claim about legal tender everywhere.

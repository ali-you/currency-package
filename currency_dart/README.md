# currency_dart

Pure Dart, offline ISO 4217 metadata with normalized lookups, immutable records,
current/historical status, categories, structured territories and minor units.
No Flutter SDK or runtime dependencies are required.

```yaml
dependencies:
  currency_dart: ^0.1.0
```

```dart
import 'package:currency_dart/currency_dart.dart';

final currencies = Currency();
final usd = currencies.byIsoCode(' usd ')!;
print(usd.currencyName); // United States dollar
print(usd.minorUnit); // 2
print(currencies.byCurrencyName('unknown')); // null
print(currencies.byIsoCode('ALL')!.numericCodeString); // 008
final current = currencies.getAllCurrencies(category: CurrencyCategory.currency);
final oldLev = currencies.byIsoCode('BGN', includeHistorical: true);
```

Display names, official names and aliases match exactly after trimming and ignoring case; missing or ambiguous names
return null. Prefer ISO codes for identifiers. Historical entries require opt-in.
Lists and their territory lists are immutable. `toJson`/`fromJson` round trip,
models compare by value, and invalid JSON produces field-specific
`FormatException`s. A missing/null name defaults to `Not defined`.

The dataset has all 178 current codes from SIX's 17 September 2026 register and
13 selected historical entries. Codes include ordinary currencies, funds, metals
and special-purpose instruments; use `CurrencyCategory` to filter them.
`CurrencyStatus` marks historical entries, and `withdrawalDate` preserves ISO's
source precision. `territories` contains complete entity strings from the register;
`territory` is the joined display label. `numericCode` remains an integer while
`numericCodeString` preserves three-digit display. `minorUnit` is the ISO decimal
exponent, or null when not applicable. `fractionalUnit` is an optional unit name.

Symbols and representative flags are optional supplemental annotations, not
ISO-verified or exhaustive territory mappings. Null means unknown or not
applicable. This package does not provide exchange rates or monetary formatting.

The data is generated from the repository's `currency.json`. Source snapshots,
publication dates and hashes are tracked in the
[repository](https://github.com/ali-you/currency-package), with source attribution
to [SIX, the ISO 4217 Maintenance Agency](https://www.six-group.com/en/products-services/financial-information/market-reference-data/data-standards.html).
The historical subset is not a complete archive.

For development in the repository, run `dart pub get --no-example`, `dart analyze`
and `dart test`. The Flutter browser in `example` is optional and has separate
Flutter dependencies. Run `dart run tool/generate.dart --check` to check generated
output against the canonical JSON.

## Migrating from 0.0.1

Current-only results are now the default. Pass `includeHistorical: true` to access
obsolete codes. Code and name inputs now trim whitespace; names ignore case and
return null for missing or ambiguous matches. Returned collections are immutable.
Territory labels and numeric codes have been reconciled with the official source.

`officialName` preserves the register name separately from the display name.
`aliases` is immutable and preserves former labels such as `Peruvian nuevo sol`;
that name and `Sol` both find PEN, whose display name is now `Peruvian sol`.
Subdivision names are independent of ISO precision. Historical null minor units
mean precision is unavailable from the historical register. Display verification
and sources are maintained in the repository's `currency.annotations.json`.

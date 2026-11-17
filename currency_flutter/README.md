# currency_flutter

Flutter currency labels backed by `currency_dart`. The public library re-exports
`CurrencyRepository`, `Currency` and `CurrencyStatus`; both packages
share the same immutable dataset.

```yaml
dependencies:
  currency_flutter: ^0.5.0
```

```dart
import 'package:currency_flutter/currency_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  final usd = CurrencyRepository().byIsoCode(' usd ')!;
  runApp(MaterialApp(
    home: Scaffold(body: Center(child: CurrencyLabel(currency: usd))),
  ));
}
```

`CurrencyLabel` renders a wrapping code/name label with an optional representative
flag. Set `showFlag: false` to hide it, and pass `style` for text styling. Its
semantic text reads the code and name without relying on the emoji.

Code/name lookups ignore case and surrounding whitespace. Missing or ambiguous
names return null. Historical codes require `includeHistorical: true`.

## Currency picker

Open a searchable Material dialog from a widget's build context:

```dart
final selected = await showCurrencyPicker(
  context: context,
  value: currentCurrency,
  historical: false,
  nonIso: true,
);
if (selected != null) {
  setState(() => currentCurrency = selected);
}
```

Dismissal returns `null`. Search matches codes, names, aliases, symbols and
territories, ignoring case and surrounding whitespace. Results are sorted by
code. Historical entries are excluded and non-ISO entries included by default.

Embed `CurrencyPicker(value: currentCurrency, onChanged: onCurrencyChanged)`
in a bounded-height layout, such as `Expanded` or `SizedBox(height: 400)`.
The parent controls the selected value. Both APIs accept `showFlag`,
`searchHintText`, `emptyText` and `nameBuilder`; the dialog also accepts `title`.
To use `currency_localization`, pass
`nameBuilder: (currency) => names.name(currency.isoCode, locale: locale)`.
Localized names are also searchable. The picker uses the surrounding Material
theme and text direction; cancel text comes from Flutter's Material localizations.

Source coverage is 155 current currencies from SIX's 17 September 2026 register,
plus 11 selected historical currencies. Flags, symbols and subdivision names are
incomplete supplemental annotations, not ISO-verified facts; null means unknown
or not applicable. This library provides no exchange rates or price formatting.
See [the repository](https://github.com/ali-you/currency-package) for provenance,
source snapshots and update instructions.

Run the browser in `example` to try code and name searches. In a repository
checkout, dependency overrides resolve the sibling core locally. Publish the core
0.5.0 release before this package; the hosted dependency is used by consumers.

## Migrating from 0.0.1

The template `Calculator` has been removed. Import this library for currency
lookups and `CurrencyLabel`; no duplicated private currency data is maintained.

## Migrating to 0.2.0

The shared core no longer exposes CurrencyCategory or the category parameter.
Only ordinary currencies are included; historical entries remain opt-in.

## Custom identifiers

All nine custom entries have status `nonIso`. Their `isoCode` field contains a
three-letter project code, such as `IRT` for toman; these are not registered
ISO 4217 codes. Check status before treating any code as an ISO identifier.
`byIsoCode('IRT')` and `byCode('IRT')` resolve the same record as
`byCode('TOMAN')`. JSON keys match isoCode. Use the required isoCode field to read the identifier.

Localization accepts either form: `names.name('IRT', locale: 'fa')` displays
`تومان ایران`. `supportedCurrencyCodes` lists the three-letter identifiers;
descriptive aliases are accepted by lookups. Numeric ISO codes remain null for nonIso.
English, Persian and Arabic names are provided; other locales use fallback.
Historical entries remain opt-in. Conversion rules are not supplied.

## Currency visibility

```dart
final currencies = CurrencyRepository();
final officialCurrent = currencies.getAllCurrencies(historical: false, nonIso: false);
final allEntries = currencies.getAllCurrencies(historical: true, nonIso: true);
```

The `historical` and `nonIso` Boolean flags are independent. Current ISO entries
are always included. Defaults are `historical: false` and `nonIso: true`.
The same flags apply to `byCode`, `byIsoCode` and `byCurrencyName`. The existing
`includeHistorical` argument remains a compatibility alias and takes precedence
when supplied. Both browser examples expose matching switches; searches respect
the selected visibility options.

Currency JSON stores only `isoCode`; each record key has the same value.
The Dart model requires a non-null `isoCode`. Project
short codes remain marked `nonIso`. Localizations use the same short keys.

## Migrating to 0.5.0

Use `CurrencyRepository()` for lookups (previously `Currency()`). Metadata values
now use `Currency` (previously `CurrencyModel`). Read `isoCode` instead of `code`;
construct models with the required `isoCode` argument. Imports from
`src/currency_model.dart` must move to the public package library.

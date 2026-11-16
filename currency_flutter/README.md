# currency_flutter

Flutter currency labels backed by `currency_dart`. The public library re-exports
`Currency`, `CurrencyModel`, `CurrencyStatus` and `CurrencyCategory`; both packages
share the same immutable dataset.

```yaml
dependencies:
  currency_flutter: ^0.1.0
```

```dart
import 'package:currency_flutter/currency_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  final usd = Currency().byIsoCode(' usd ')!;
  runApp(MaterialApp(
    home: Scaffold(body: Center(child: CurrencyLabel(currency: usd))),
  ));
}
```

`CurrencyLabel` renders a wrapping code/name label with an optional representative
flag. Set `showFlag: false` to hide it, and pass `style` for text styling. Its
semantic text reads the code and name without relying on the emoji.

Code/name lookups ignore case and surrounding whitespace. Missing or ambiguous
names return null. Historical codes require `includeHistorical: true`. For a
currency picker, use `Currency().getAllCurrencies(category:
CurrencyCategory.currency)` to exclude funds, metals and special-purpose codes.

Source coverage is all 178 current ISO codes from SIX's 17 September 2026 register,
plus 13 selected historical entries. Flags, symbols and subdivision names are
incomplete supplemental annotations, not ISO-verified facts; null means unknown
or not applicable. This library provides no exchange rates or price formatting.
See [the repository](https://github.com/ali-you/currency-package) for provenance,
source snapshots and update instructions.

Run the browser in `example` to try code and name searches. In a repository
checkout, dependency overrides resolve the sibling core locally. Publish the core
0.1.0 release before this package; the hosted dependency is used by consumers.

## Migrating from 0.0.1

The template `Calculator` has been removed. Import this library for currency
lookups and `CurrencyLabel`; no duplicated private currency data is maintained.

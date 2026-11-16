# currency_flutter

Flutter currency labels backed by `currency_dart`. The public library re-exports
`Currency`, `CurrencyModel` and `CurrencyStatus`; both packages
share the same immutable dataset.

```yaml
dependencies:
  currency_flutter: ^0.2.0
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
currency picker, use `Currency().getAllCurrencies()`.

Source coverage is 155 current currencies from SIX's 17 September 2026 register,
plus 11 selected historical currencies. Flags, symbols and subdivision names are
incomplete supplemental annotations, not ISO-verified facts; null means unknown
or not applicable. This library provides no exchange rates or price formatting.
See [the repository](https://github.com/ali-you/currency-package) for provenance,
source snapshots and update instructions.

Run the browser in `example` to try code and name searches. In a repository
checkout, dependency overrides resolve the sibling core locally. Publish the core
0.2.0 release before this package; the hosted dependency is used by consumers.

## Migrating from 0.0.1

The template `Calculator` has been removed. Import this library for currency
lookups and `CurrencyLabel`; no duplicated private currency data is maintained.

## Migrating to 0.2.0

The shared core no longer exposes CurrencyCategory or the category parameter.
Only ordinary currencies are included; historical entries remain opt-in.

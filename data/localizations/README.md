# Currency name translations

Each `<locale>.json` is a project-maintained ISO-code-to-localized-name map.
Edit these files directly; no source version directory or external import is
required. Missing names are omitted to enable runtime fallback.

Add a locale file or change translations, then run from `currency_localization`:

```sh
dart run tool/generate.dart
dart run tool/generate.dart --check
dart test
```

Locale parent overrides are stored in `data/locale_parents.json`. Generated
checksums and coverage are in `currency_localization/data_coverage.json`.
Root `currency.json` defines which currency codes the maps may contain.

Resource: [Unicode CLDR](https://cldr.unicode.org/) supplied the initial currency
names and parent mappings. The project maintains the compact maps independently.
The derived data's Unicode License V3 notice remains in
`currency_localization/third_party/UNICODE_LICENSE.txt`.

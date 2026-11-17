# Currency data

- `currency.json`: canonical dataset consumed by Dart generators.
- `currency.metadata.json`: source references and record counts.
- `currency.annotations.json`: curated display values and verification details.
- `currency.schema.json`: dataset and annotation validation schema.
- `custom_currencies.json`: maintained non-ISO entries merged into the dataset.
- `custom_currency_sources.json`: evidence for those custom entries.

Run `python scripts/refresh_data.py` from the repository root after updating
annotations or custom entries. Use `--check` for a read-only consistency check.
Validate with `python scripts/validate_currency.py`, then regenerate each package
with `dart run tool/generate.dart` from its package directory. Translation maps
remain in `data/localizations`; original ISO snapshots are in
`data/sources/currencies`.

Currency JSON stores only `isoCode`; each record key has the same value.
The Dart model requires a non-null `isoCode`. Project
short codes remain marked `nonIso`. Localizations use the same short keys.

`territory_country_codes.json` maps register and custom territory labels to
country codes for `countryIsoCodes`. The collective EUROPEAN UNION label is
expanded to euro-using territories, informed by Unicode CLDR currency data
(https://github.com/unicode-org/cldr/blob/main/common/supplemental/supplementalData.xml).
Mappings describe the bundled snapshot, not every unofficial use. The former
Netherlands Antilles has no current ISO 3166-1 code and maps to an empty list.

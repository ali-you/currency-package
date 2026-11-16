# Pinned Unicode CLDR currency names

`49.0.0/<locale>.json` (657 locales) are unmodified `currencies.json` downloads from the
official `unicode-org/cldr-json` repository, tag `49.0.0`:

https://github.com/unicode-org/cldr-json/tree/49.0.0/cldr-json/cldr-numbers-full/main

`parentLocales.json` is from the matching cldr-core supplemental directory.

The files are licensed under the Unicode License V3. The unmodified upstream
license is included at `currency_localization/third_party/UNICODE_LICENSE.txt`.
SHA-256 hashes, source URLs, version and translation coverage are recorded in
`currency_localization/data_provenance.json`. Git attributes preserve original
snapshot and license bytes across checkouts.

From `currency_localization`, run `dart run tool/generate.dart` to extract the
`displayName` for each code in the root `currency.json`, or add `--check` to
verify generated output without changing it. Missing/code-only values are left
out so runtime locale fallback works per currency. Other CLDR fields, including
plural forms and symbols, are intentionally not extracted. See the package
README for adding locales and updating the pinned version.

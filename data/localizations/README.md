# Currency name translations

Each `<locale>.json` is a project-maintained code-to-localized-name map.
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
Root `data/currencies/currency.json` defines which currency codes the maps may contain.

Resource: [Unicode CLDR](https://cldr.unicode.org/) supplied the initial currency
names and parent mappings. The project maintains the compact maps independently.
The derived data's Unicode License V3 notice remains in
`currency_localization/third_party/UNICODE_LICENSE.txt`.

Custom codes use the same map structure. All nine curated entries have project translations in English, Persian, Arabic
and 59 additional locale maps, including Simplified/Traditional Chinese and
Cantonese. Regional locales inherit these names through their language/script
parents. Untranslated languages continue to use normal fallback.

Locale maps use the three-letter isoCode field as their key, including project
codes such as IRT for nonIso records. Descriptive identifiers are resolved as
compatibility aliases by the package and are not duplicated in JSON.

English, Persian and Arabic cover every supported currency. VED uses the
existing localized bolívar name in every map that has a VES translation;
the two currency codes remain distinct. Additional Salvadoran colón (SVC)
translations are maintained in the language maps and inherited by regional
locales. Other gaps retain normal locale and English fallback; an English
fallback is not recorded as a native translation. The generator requires a
complete English map so supported currencies never fall back to a bare code.

Chinese regional tags `zh-CN` and `zh-SG` resolve to Simplified Chinese parents;
`zh-TW`, `zh-HK` and `zh-MO` resolve to Traditional Chinese parents.

Audit effective coverage after parent-locale inheritance from `currency_localization`:

```sh
dart run tool/audit.dart
dart run tool/audit.dart --json
```

The audit uses `lookup`, which excludes configured and English fallback. Its JSON
output lists missing native names and missing non-ISO codes for every locale.
Currently 367 of 657 locales resolve all nine non-ISO names without English
fallback. Unsupported native translations remain omitted rather than being
recorded as English translations.

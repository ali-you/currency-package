## 0.6.2

* Add all nine non-ISO currency names to 59 additional locale maps, including
  Simplified/Traditional Chinese and Cantonese.
* Resolve Chinese regional tags to the appropriate Simplified/Traditional parents.
* Test non-ISO short and descriptive identifiers, regional inheritance and scripts.
* Add a native-coverage audit with per-locale missing-code JSON output.
* Reach complete non-ISO coverage in 367 supported locales after inheritance.

## 0.6.1

* Add 374 localized labels across 325 locale maps, including SVC and VED.
* Complete English, Persian and Arabic coverage for all 175 supported currencies.
* Require complete English fallback data during generation.
* Verify display-name resolution for every currency across all 657 supported locales.
* Preserve script boundaries and configured fallback for untranslated names.

## 0.6.0

* Use short currency codes as record keys and isoCode as the single stored identifier.
* Keep the Dart code getter and descriptive lookup aliases for compatibility.
* Fill non-ISO display metadata and document neutral flag placeholders.
* Synchronize currency and localization generation with the simplified schema.

## 0.5.0

* Add nine non-ISO units, local variants and community currencies with explicit statuses.
* Add general code identifiers; ISO codes are nullable for custom entries.
* Provide English, Persian and Arabic custom names with fallback elsewhere.

## 0.4.0

* Include only current and selected historical currencies; exclude funds, metals and special codes.
* Remove category metadata and filtering from the shared currency API.

## 0.3.0

* Compact locale JSON to ISO-code/name maps with separate provenance.
* Maintain translations directly under data/localizations without source-version coupling.
* Remove source-specific version getter and importer; retain license attribution.

## 0.2.0

* Expand from three languages to all 657 locale datasets.
* Preserve script/regional names and honor explicit parent overrides.
* Discover locales automatically and record coverage and parent-source hashes.

## 0.1.0

* Add offline English, Persian and Arabic currency display names.
* Support normalized ISO codes and locale tags, parent and configurable fallback.
* Expose direct lookups, supported locales/codes and immutable bulk name maps.
* Preserve Unicode licensing, source snapshots, hashes and coverage metadata.

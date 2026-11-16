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

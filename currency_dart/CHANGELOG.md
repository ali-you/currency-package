## 0.5.0

* Breaking: rename the lookup service from Currency to CurrencyRepository and
  the metadata model from CurrencyModel to Currency.
* Require isoCode in the model; remove the legacy code constructor argument/getter.
* Add representative countryIsoCode and immutable countryIsoCodes metadata.
* Complete missing currency symbols and flags, including MRU and SLE.

## 0.4.0

* Use short currency codes as record keys and isoCode as the single stored identifier.
* Keep the Dart code getter and descriptive lookup aliases for compatibility.
* Fill non-ISO display metadata and document neutral flag placeholders.
* Synchronize currency and localization generation with the simplified schema.

## 0.3.0

* Add independent historical/nonIso Boolean filters to lists and lookups.
* Expose visibility switches in the browser example; preserve legacy history argument.
* Add nine non-ISO units, local variants and community currencies with explicit statuses.
* Add general code identifiers; ISO codes are nullable for custom entries.
* Provide English, Persian and Arabic custom names with fallback elsewhere.

## 0.2.0

* Include only current and selected historical currencies; exclude funds, metals and special codes.
* Remove category metadata and filtering from the shared currency API.

## Unreleased

* Correct PEN and XCG display metadata; normalize missing subdivision names.
* Add official names and compatible search aliases to shared metadata.
* Track display annotation provenance and validate JSON schema and invariants.

## 0.1.0

* Make the core independent of Flutter.
* Normalize lookups and return null for missing/ambiguous names.
* Refresh all current ISO codes; retain selected historical codes behind opt-in.
* Add status, category, structured territories, minor units and padded numeric codes.
* Generate immutable data from one canonical JSON source with provenance checks.
* Add validated JSON parsing, value equality, round trips and currency tests.
* Repair the browser example and add automated package checks.

## 0.0.1

* Initial metadata and lookups.

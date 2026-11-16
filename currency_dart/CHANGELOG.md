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

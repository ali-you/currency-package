# ISO register snapshots

`list-one.xml` and `list-three.xml` are unmodified public ISO 4217 register
downloads from SIX, the ISO 4217 Maintenance Agency:

- https://www.six-group.com/dam/download/financial-information/data-center/iso-currrency/lists/list-one.xml
- https://www.six-group.com/dam/download/financial-information/data-center/iso-currrency/lists/list-three.xml

Publication dates and SHA-256 hashes are recorded in `currency.metadata.json`.
The XML snapshots are marked `-text` in `.gitattributes` to preserve source bytes
and hashes across Windows and Linux checkouts.
Preserve upstream source attribution when updating or redistributing this data.

To refresh, download both registers to these paths, run
`python scripts/refresh_data.py`, then run `dart run tool/generate.dart` from
`currency_dart`. Review the resulting data diff. `--check` on either command
validates the checked-in data without downloading anything.

The JSON is the single input to Dart generation. ISO codes, numeric codes,
entities, minor-unit exponents, and withdrawal dates come from the registers.
Existing display names, symbols, subdivision names, and representative flags are
supplemental annotations; update these in `currency.annotations.json`. Each field
records its verification status, source URLs and verification date. Legacy values
remain explicitly unverified. They are not claimed to be ISO-verified. Newly added currencies may have null annotations rather than
guessed values. Categories are maintained by this package. Historical coverage
includes only original package codes; this is not a complete historical archive.

`officialName` is always sourced from the register. `currencyName` is a display
name; `aliases` preserves replaced display names for compatible searches.
`flag` is only a representative display choice, not a territory mapping. Historical
`minorUnit: null` means the historical register does not supply that precision.
`fractionalUnit` is an optional subdivision name; never calculate precision or a
conversion factor from it. Missing or questionable annotations stay null.

Install validator dependencies with `python -m pip install -r scripts/requirements.txt`.
Run `python scripts/validate_currency.py` and
`python -m unittest discover -s scripts -p 'test_*.py'` after editing annotations.
The external `currency.schema.json` validates the data without adding metadata
keys to the currency-code map; the validator additionally checks cross-field
consistency and annotation provenance. CI runs these checks.

The refresh script includes only ordinary currencies. Explicit exclusion codes
and the register fund marker prevent metals, funds, accounting units and special
codes from being reintroduced. Shared currencies with an X prefix are retained.

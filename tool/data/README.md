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
`python tool/refresh_data.py`, then run `dart run tool/generate.dart` from
`currency_dart`. Review the resulting data diff. `--check` on either command
validates the checked-in data without downloading anything.

The JSON is the single input to Dart generation. ISO codes, numeric codes,
entities, minor-unit exponents, and withdrawal dates come from the registers.
Existing display names, symbols, subdivision names, and representative flags are
supplemental annotations; update these in `currency.json`. They are not claimed
to be ISO-verified. Newly added currencies may have null annotations rather than
guessed values. Categories are maintained by this package. Historical coverage
includes only original package codes; this is not a complete historical archive.

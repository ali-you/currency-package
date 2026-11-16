"""Validate currency data, annotation provenance, and cross-field invariants."""

import json
from pathlib import Path

from jsonschema import Draft202012Validator, FormatChecker

from refresh_data import EXCLUDED_CODES

ROOT = Path(__file__).resolve().parents[1]


def load(path):
    def unique(items):
        result = {}
        for key, value in items:
            if key in result:
                raise ValueError(f"Duplicate JSON key: {key}")
            result[key] = value
        return result
    return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique)


def validate(data, annotations, schema):
    Draft202012Validator.check_schema(schema)
    Draft202012Validator(schema, format_checker=FormatChecker()).validate(data)
    annotation_schema = {
        "$ref": "#/$defs/annotations", "$defs": schema["$defs"],
    }
    Draft202012Validator(annotation_schema, format_checker=FormatChecker()).validate(annotations)
    short_codes = set()
    for code, row in data.items():
        short = row["isoCode"]
        if short in short_codes or (short in data and short != code):
            raise ValueError(f"{code}: duplicate or colliding short code")
        short_codes.add(short)
        if code in EXCLUDED_CODES:
            raise ValueError(f"{code}: non-currency code is excluded")
        if row["isoCode"] != code:
            raise ValueError(f"{code}: ISO identifier must match code")
        if row["territory"] != (", ".join(row["territories"]) or None):
            raise ValueError(f"{code}: territory must match territories")
        if row["fractionalUnit"] == row["currencyName"]:
            raise ValueError(f"{code}: currency name is not a subdivision name")
        aliases = row["aliases"]
        if len({alias.strip().casefold() for alias in aliases}) != len(aliases):
            raise ValueError(f"{code}: duplicate normalized aliases")
    for code, annotation in annotations.items():
        if code not in data:
            raise ValueError(f"Unknown annotation code: {code}")
        row = data[code]
        if row["aliases"] != annotation["aliases"]:
            raise ValueError(f"{code}: annotation aliases are stale")
        for field, item in annotation["fields"].items():
            if row[field] != item["value"]:
                raise ValueError(f"{code}: annotation value differs for {field}")


if __name__ == "__main__":
    validate(load(ROOT / "data/currencies/currency.json"), load(ROOT / "data/currencies/currency.annotations.json"),
             load(ROOT / "data/currencies/currency.schema.json"))
    print("Currency schema, provenance, and cross-field checks passed.")

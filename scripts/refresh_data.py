"""Merge pinned SIX registers into data/currencies/currency.json; no network access required.

ISO facts come from XML. Display metadata comes from data/currencies/currency.annotations.json,
which distinguishes verified annotations from inherited, unverified values.
Historical coverage intentionally retains only codes already in data/currencies/currency.json.
"""

import argparse
import hashlib
import json
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
SIX = "https://www.six-group.com/dam/download/financial-information/data-center/iso-currrency/lists/"
METALS = {"XAG", "XAU", "XPD", "XPT"}
FUNDS = {
    "BOV", "CHE", "CHW", "CLF", "COU", "MXV", "USN", "USS", "UYI",
    "UYW", "XAD", "XBA", "XBB", "XBC", "XBD", "XDR", "XFU", "XSU", "XUA",
}


def group_entries(root, table, tag):
    groups = {}
    for entry in root.findall(f"{table}/{tag}"):
        code = entry.findtext("Ccy")
        if code:
            groups.setdefault(code, []).append(entry)
    return groups


EXCLUDED_CODES = METALS | FUNDS | {"XTS", "XXX"}


def is_currency(code, entries):
    # Shared currencies such as XAF/XOF/XCD are intentionally retained.
    return code not in EXCLUDED_CODES and not any(
        e.find("CcyNm").get("IsFund") == "true" for e in entries
    )


def country_iso_code(flag):
    """Decode the representative country flag; EU is not a country code."""
    if not flag or len(flag) != 2 or not all(0x1F1E6 <= ord(c) <= 0x1F1FF for c in flag):
        return None
    code = "".join(chr(ord(c) - 0x1F1E6 + ord("A")) for c in flag)
    return None if code == "EU" else code


def build():
    country_codes = json.loads((ROOT / "data/currencies/territory_country_codes.json").read_text(encoding="utf-8"))
    previous = json.loads((ROOT / "data/currencies/currency.json").read_text(encoding="utf-8"))
    annotations = json.loads((ROOT / "data/currencies/currency.annotations.json").read_text(encoding="utf-8"))
    current_path = ROOT / "data/sources/currencies/list-one.xml"
    historical_path = ROOT / "data/sources/currencies/list-three.xml"
    current = ET.parse(current_path).getroot()
    historical = ET.parse(historical_path).getroot()
    current_groups = group_entries(current, "CcyTbl", "CcyNtry")
    historical_groups = group_entries(historical, "HstrcCcyTbl", "HstrcCcyNtry")
    custom = json.loads((ROOT / "data/currencies/custom_currencies.json").read_text(encoding="utf-8"))
    result = {}
    for code in sorted(set(current_groups) | set(previous)):
        if code in custom:
            continue
        old = previous.get(code, {})
        annotation = annotations.get(code, {"fields": {}, "aliases": []})
        fields = {key: item["value"] for key, item in annotation["fields"].items()}
        is_current = code in current_groups
        entries = current_groups.get(code) or historical_groups.get(code)
        if not entries:
            raise ValueError(f"{code} is absent from both ISO registers")
        if not is_currency(code, entries):
            continue
        if not is_current:
            # A code may have multiple historical assignments. Preserve the
            # numeric assignment already represented by the package.
            matching = [e for e in entries if e.findtext("CcyNbr") and
                        int(e.findtext("CcyNbr")) == old.get("numericCode")]
            if matching:
                entries = matching
        numbers = {e.findtext("CcyNbr") for e in entries}
        if len(numbers) != 1:
            raise ValueError(f"Ambiguous numeric assignment for {code}: {numbers}")
        entities = sorted({e.findtext("CtryNm").strip() for e in entries
                           if not e.findtext("CtryNm").startswith("ZZ")})
        minor_units = {e.findtext("CcyMnrUnts") for e in entries}
        if is_current and len(minor_units) != 1:
            raise ValueError(f"Ambiguous minor unit for {code}")
        minor_unit = entries[0].findtext("CcyMnrUnts")
        number = next(iter(numbers))
        result[code] = {
            "isoCode": code,
            "currencyName": fields.get("currencyName") or entries[0].findtext("CcyNm"),
            "officialName": entries[0].findtext("CcyNm"),
            "aliases": annotation["aliases"],
            "numericCode": int(number) if number else None,
            "currencySymbol": fields.get("currencySymbol"),
            "territory": ", ".join(entities) or None,
            "fractionalUnit": fields.get("fractionalUnit"),
            "flag": fields.get("flag"),
            "territories": entities,
            "minorUnit": int(minor_unit) if minor_unit and minor_unit.isdigit() else None,
            "status": "current" if is_current else "historical",
            "withdrawalDate": None if is_current else max(
                e.findtext("WthdrwlDt") for e in entries
            ),
        }
    if set(custom) & set(result):
        raise ValueError("Custom code collides with ISO code")
    result.update(custom)
    for row in result.values():
        row["countryIsoCode"] = country_iso_code(row.get("flag"))
        row["countryIsoCodes"] = sorted({country for territory in row["territories"]
                                           for country in country_codes[territory]})
    result = dict(sorted(result.items()))
    sources = [
        {"url": SIX + p.name, "published": tree.get("Pblshd"),
         "sha256": hashlib.sha256(p.read_bytes()).hexdigest()}
        for p, tree in [(current_path, current), (historical_path, historical)]
    ]
    metadata = {
        "sources": sources,
        "coverage": "Ordinary currencies from the current ISO register plus selected historical currencies. Funds, metals and special-purpose codes are excluded. Nine curated non-ISO entries are included with explicit statuses.",
        "customCount": len(custom),
        "customSources": "data/currencies/custom_currency_sources.json",
        "currentCount": sum(row["status"] == "current" for row in result.values()),
        "historicalCount": sum(row["status"] == "historical" for row in result.values()),
        "annotations": "Display metadata and field-level sources are maintained in data/currencies/currency.annotations.json. Inherited annotations are explicitly unverified. Null means unknown or not applicable; historical minor units are unavailable in List Three. Flags are representative, not exhaustive.",
    }
    return {"data/currencies/currency.json": result, "data/currencies/currency.metadata.json": metadata}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Fail on register/data drift")
    args = parser.parse_args()
    for name, data in build().items():
        content = json.dumps(data, ensure_ascii=False, indent=2) + "\n"
        path = ROOT / name
        if args.check:
            if path.read_text(encoding="utf-8") != content:
                raise SystemExit(f"{name} is stale; run python scripts/refresh_data.py")
        else:
            path.write_text(content, encoding="utf-8", newline="\n")


if __name__ == "__main__":
    main()

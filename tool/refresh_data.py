"""Merge pinned SIX registers into currency.json; no network access required.

ISO facts come from XML. Display metadata comes from currency.annotations.json,
which distinguishes verified annotations from inherited, unverified values.
Historical coverage intentionally retains only codes already in currency.json.
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


def category(code, entries):
    if code in METALS:
        return "preciousMetal"
    if code in {"XTS", "XXX"}:
        return "special"
    if code in FUNDS or any(e.find("CcyNm").get("IsFund") == "true" for e in entries):
        return "fund"
    return "currency"


def build():
    previous = json.loads((ROOT / "currency.json").read_text(encoding="utf-8"))
    annotations = json.loads((ROOT / "currency.annotations.json").read_text(encoding="utf-8"))
    current_path = ROOT / "tool/data/list-one.xml"
    historical_path = ROOT / "tool/data/list-three.xml"
    current = ET.parse(current_path).getroot()
    historical = ET.parse(historical_path).getroot()
    current_groups = group_entries(current, "CcyTbl", "CcyNtry")
    historical_groups = group_entries(historical, "HstrcCcyTbl", "HstrcCcyNtry")
    result = {}
    for code in sorted(set(current_groups) | set(previous)):
        old = previous.get(code, {})
        annotation = annotations.get(code, {"fields": {}, "aliases": []})
        fields = {key: item["value"] for key, item in annotation["fields"].items()}
        is_current = code in current_groups
        entries = current_groups.get(code) or historical_groups.get(code)
        if not entries:
            raise ValueError(f"{code} is absent from both ISO registers")
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
        kind = category(code, entries)
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
            "flag": fields.get("flag") if kind == "currency" else None,
            "territories": entities,
            "minorUnit": int(minor_unit) if minor_unit and minor_unit.isdigit() else None,
            "status": "current" if is_current else "historical",
            "category": kind,
            "withdrawalDate": None if is_current else max(
                e.findtext("WthdrwlDt") for e in entries
            ),
        }
    sources = [
        {"url": SIX + p.name, "published": tree.get("Pblshd"),
         "sha256": hashlib.sha256(p.read_bytes()).hexdigest()}
        for p, tree in [(current_path, current), (historical_path, historical)]
    ]
    metadata = {
        "sources": sources,
        "coverage": "All current ISO 4217 codes plus selected historical codes retained from the original dataset.",
        "currentCount": len(current_groups),
        "historicalCount": len(result) - len(current_groups),
        "annotations": "Display metadata and field-level sources are maintained in currency.annotations.json. Inherited annotations are explicitly unverified. Null means unknown or not applicable; historical minor units are unavailable in List Three. Flags are representative, not exhaustive. Categories are package-defined groupings.",
    }
    return {"currency.json": result, "currency.metadata.json": metadata}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Fail on register/data drift")
    args = parser.parse_args()
    for name, data in build().items():
        content = json.dumps(data, ensure_ascii=False, indent=2) + "\n"
        path = ROOT / name
        if args.check:
            if path.read_text(encoding="utf-8") != content:
                raise SystemExit(f"{name} is stale; run python tool/refresh_data.py")
        else:
            path.write_text(content, encoding="utf-8", newline="\n")


if __name__ == "__main__":
    main()

import copy
import unittest

from jsonschema import ValidationError

from validate_currency import ROOT, load, validate


class CurrencyValidationTests(unittest.TestCase):
    def test_non_iso_short_codes_cannot_collide_with_iso_codes(self):
        self.data['TOMAN']['isoCode'] = 'IRR'
        with self.assertRaisesRegex(ValueError, 'short code'):
            self.check()

    def test_refresh_excludes_non_currencies_and_preserves_shared_currencies(self):
        from refresh_data import build, EXCLUDED_CODES
        data = build()['data/currencies/currency.json']
        self.assertFalse(set(data) & EXCLUDED_CODES)
        self.assertTrue({'EUR', 'XAF', 'XOF', 'XCD', 'XPF', 'XCG'} <= set(data))
        self.assertTrue(all('category' not in row for row in data.values()))
        self.assertEqual(data['TOMAN']['status'], 'nonIso')
        self.assertEqual(data['TOMAN']['isoCode'], 'IRT')
        self.assertEqual(len([row for row in data.values() if row['status'] == 'nonIso']), 9)

    def setUp(self):
        self.data = load(ROOT / "data/currencies/currency.json")
        self.annotations = load(ROOT / "data/currencies/currency.annotations.json")
        self.schema = load(ROOT / "data/currencies/currency.schema.json")

    def check(self):
        validate(self.data, self.annotations, self.schema)

    def test_canonical_data_passes(self):
        self.check()

    def test_rejects_invalid_metadata_types_values_and_status_dates(self):
        original = copy.deepcopy(self.data)
        for field, value in [
            ("numericCode", "840"), ("minorUnit", -1),
            ("fractionalUnit", "None"), ("status", "obsolete"),
            ("withdrawalDate", "2026-13"), ("unexpected", True),
            ("territories", ["UNITED STATES", "UNITED STATES"]),
        ]:
            with self.subTest(field=field):
                self.data = copy.deepcopy(original)
                self.data["USD"][field] = value
                with self.assertRaises(ValidationError):
                    self.check()

    def test_rejects_mismatched_code_and_joined_territory(self):
        self.data["USD"]["code"] = "EUR"
        with self.assertRaisesRegex(ValueError, "code"):
            self.check()
        self.data["USD"]["code"] = "USD"
        self.data["USD"]["territory"] = "Incorrect"
        with self.assertRaisesRegex(ValueError, "territory"):
            self.check()

    def test_verified_annotations_require_sources(self):
        self.annotations["PEN"]["fields"]["currencySymbol"]["sources"] = []
        with self.assertRaises(ValidationError):
            self.check()

    def test_annotation_drift_is_rejected(self):
        self.data["PEN"]["currencySymbol"] = "S/."
        with self.assertRaisesRegex(ValueError, "annotation value"):
            self.check()


if __name__ == "__main__":
    unittest.main()

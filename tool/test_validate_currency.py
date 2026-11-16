import copy
import unittest

from jsonschema import ValidationError

from validate_currency import ROOT, load, validate


class CurrencyValidationTests(unittest.TestCase):
    def setUp(self):
        self.data = load(ROOT / "currency.json")
        self.annotations = load(ROOT / "currency.annotations.json")
        self.schema = load(ROOT / "currency.schema.json")

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
        self.data["USD"]["isoCode"] = "EUR"
        with self.assertRaisesRegex(ValueError, "isoCode"):
            self.check()
        self.data["USD"]["isoCode"] = "USD"
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

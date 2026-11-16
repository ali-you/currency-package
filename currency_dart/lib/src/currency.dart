import 'currency_model.dart';
import 'currency_repo.dart';

/// Offline lookups of ISO 4217 currencies, funds, and special-purpose codes.
class Currency {
  static final List<CurrencyModel> _all = List.unmodifiable(
    CurrencyRepo.currencies.values.map(CurrencyModel.fromJson),
  );
  static final Map<String, CurrencyModel> _byCode = Map.unmodifiable({
    for (final currency in _all) currency.isoCode: currency,
  });
  static final List<CurrencyModel> _current = List.unmodifiable(
    _all.where((currency) => currency.status == CurrencyStatus.current),
  );

  /// Returns an immutable list, optionally including historical codes.
  List<CurrencyModel> getAllCurrencies({
    bool includeHistorical = false,
    CurrencyCategory? category,
  }) {
    final currencies = includeHistorical ? _all : _current;
    return category == null
        ? currencies
        : List.unmodifiable(currencies.where((c) => c.category == category));
  }

  /// Ignores surrounding whitespace and case. Unknown/excluded codes return null.
  CurrencyModel? byIsoCode(String isoCode, {bool includeHistorical = false}) {
    final currency = _byCode[isoCode.trim().toUpperCase()];
    return currency != null &&
            (includeHistorical || currency.status == CurrencyStatus.current)
        ? currency
        : null;
  }

  /// Exact display, official-name or alias lookup, ignoring whitespace and case.
  /// Missing or ambiguous names return null; prefer ISO codes for ambiguity.
  CurrencyModel? byCurrencyName(
    String currencyName, {
    bool includeHistorical = false,
  }) {
    final name = currencyName.trim().toLowerCase();
    CurrencyModel? match;
    for (final currency in includeHistorical ? _all : _current) {
      final names = [
        currency.currencyName,
        currency.officialName,
        ...currency.aliases
      ];
      if (names.any((candidate) => candidate?.toLowerCase() == name)) {
        if (match != null) return null;
        match = currency;
      }
    }
    return match;
  }
}

import 'currency_model.dart';
import 'currency_repo.dart';

/// Offline lookups of ISO currencies and curated non-ISO entries.
class Currency {
  static final List<CurrencyModel> _all = List.unmodifiable(
    CurrencyRepo.currencies.values.map(CurrencyModel.fromJson),
  );
  static final Map<String, CurrencyModel> _byCode = Map.unmodifiable({
    for (final currency in _all) currency.code: currency,
    for (final currency in _all)
      if (currency.isoCode != null) currency.isoCode!: currency,
    for (final currency in _all)
      for (final alias in currency.aliases)
        if (RegExp(r'^[A-Z][A-Z0-9_]{2,63}$').hasMatch(alias)) alias: currency,
  });
  static final List<CurrencyModel> _current = List.unmodifiable(
    _all.where((currency) => currency.status != CurrencyStatus.historical),
  );

  /// Returns an immutable list with independent history and non-ISO controls.
  /// Current ISO currencies are always included. [includeHistorical] is the
  /// legacy alias for [historical] and takes precedence when provided.
  List<CurrencyModel> getAllCurrencies({
    bool historical = false,
    bool nonIso = true,
    bool? includeHistorical,
  }) {
    final history = includeHistorical ?? historical;
    final source = history ? _all : _current;
    return nonIso
        ? source
        : List.unmodifiable(
            source
                .where((currency) => currency.status != CurrencyStatus.nonIso),
          );
  }

  /// Looks up a descriptive or short code using the same visibility controls.
  CurrencyModel? byCode(
    String code, {
    bool historical = false,
    bool nonIso = true,
    bool? includeHistorical,
  }) {
    final currency = _byCode[code.trim().toUpperCase()];
    return currency != null &&
            ((includeHistorical ?? historical) ||
                currency.status != CurrencyStatus.historical) &&
            (nonIso || currency.status != CurrencyStatus.nonIso)
        ? currency
        : null;
  }

  /// Looks up an ISO or project short code; check status for nonIso records.
  CurrencyModel? byIsoCode(
    String isoCode, {
    bool historical = false,
    bool nonIso = true,
    bool? includeHistorical,
  }) {
    final currency = byCode(isoCode,
        historical: historical,
        nonIso: nonIso,
        includeHistorical: includeHistorical);
    return currency?.isoCode == isoCode.trim().toUpperCase() ? currency : null;
  }

  /// Exact display, official-name or alias lookup, ignoring whitespace and case.
  /// Missing or ambiguous names return null; prefer ISO codes for ambiguity.
  CurrencyModel? byCurrencyName(
    String currencyName, {
    bool historical = false,
    bool nonIso = true,
    bool? includeHistorical,
  }) {
    final name = currencyName.trim().toLowerCase();
    CurrencyModel? match;
    for (final currency in getAllCurrencies(
        historical: historical,
        nonIso: nonIso,
        includeHistorical: includeHistorical)) {
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

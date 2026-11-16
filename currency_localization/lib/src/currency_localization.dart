import 'currency_names.dart';

/// Localized currency display names without Flutter or runtime dependencies.
///
/// Names identify currencies in pickers and labels; they are not pluralized
/// amount strings. This class does not format money or change currency metadata.
class CurrencyLocalization {
  const CurrencyLocalization({this.fallbackLocale = 'en'});

  /// Fallback after the requested locale's parents, before English and ISO code.
  final String fallbackLocale;

  /// Exact locale datasets bundled with this release, including regional and script variants (normalized lowercase tags).
  Set<String> get supportedLocales => currencyNameLocales;

  /// Codes covered by the package's pinned currency metadata snapshot.
  Set<String> get supportedCurrencyCodes => currencyNameCodes;

  /// Whether this locale or one of its parent tags has a bundled dataset.
  /// Does not count the configured fallback or English as locale support.
  bool supportsLocale(String locale) =>
      _parents(locale).any(localizedCurrencyNames.containsKey);

  /// Finds a name in the requested locale or its parents only.
  /// Returns null if no translation exists, without applying fallback locales.
  String? lookup(String isoCode, {required String locale}) {
    final code = isoCode.trim().toUpperCase();
    for (final candidate in _parents(locale)) {
      final name = localizedCurrencyNames[candidate]?[code];
      if (name != null) return name;
    }
    return null;
  }

  /// Returns a localized name, ignoring code case and surrounding whitespace.
  ///
  /// Resolution: requested locale and parents, [fallbackLocale] and parents,
  /// English, then the trimmed uppercase input code. Empty input returns empty.
  /// Hyphenated and underscore-separated locale tags are accepted. Malformed
  /// locale tags have no direct match and follow the same fallback policy.
  String name(String isoCode, {String locale = 'en'}) =>
      lookup(isoCode, locale: locale) ??
      lookup(isoCode, locale: fallbackLocale) ??
      lookup(isoCode, locale: 'en') ??
      isoCode.trim().toUpperCase();

  /// Builds an immutable map keyed by normalized ISO codes.
  /// Repeated codes are collapsed; names use the same fallback as [name].
  Map<String, String> names(Iterable<String> isoCodes,
          {String locale = 'en'}) =>
      Map.unmodifiable({
        for (final code in isoCodes)
          code.trim().toUpperCase(): name(code, locale: locale),
      });

  static Iterable<String> _parents(String locale) sync* {
    final normalized = locale.trim().replaceAll('_', '-').toLowerCase();
    if (!RegExp(r'^[a-z]{2,8}(?:-[a-z0-9]{1,8})*$').hasMatch(normalized)) {
      return;
    }
    final parts = normalized.split('-');
    // Unicode extensions and private-use suffixes do not select currency names.
    final extension = parts.indexWhere((part) => part.length == 1);
    if (extension >= 0) parts.removeRange(extension, parts.length);
    var candidate = parts.join('-');
    final visited = <String>{};
    while (
        candidate.isNotEmpty && candidate != 'root' && visited.add(candidate)) {
      yield candidate;
      final explicit = currencyLocaleParents[candidate];
      if (explicit != null) {
        candidate = explicit;
      } else {
        final separator = candidate.lastIndexOf('-');
        candidate = separator < 0 ? '' : candidate.substring(0, separator);
      }
    }
  }
}

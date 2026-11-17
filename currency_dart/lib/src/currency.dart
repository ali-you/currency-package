/// ISO lifecycle or the declared role of an active non-ISO entry.
enum CurrencyStatus { current, historical, nonIso }

/// Immutable currency metadata. Null means unknown or not applicable.
class Currency {
  final String currencyName;

  /// Name from the ISO register, separate from the curated display name.
  final String? officialName;

  /// Alternative display names retained for compatible name searches.
  final List<String> aliases;
  final String? currencySymbol;

  /// ISO code for current/historical entries; project short code for nonIso.
  /// Always check status before treating this value as ISO 4217 registered.
  final String isoCode;
  final int? numericCode;

  /// Display label retained for compatibility. Use [territories] for lists.
  final String? territory;

  /// Subdivision name, not a decimal precision.
  final String? fractionalUnit;

  /// Representative flag, not an exhaustive territory mapping.
  final String? flag;

  /// Representative ISO 3166-1 alpha-2 country code, not all territories.
  /// Null when no representative country is available.
  final String? countryIsoCode;

  /// ISO 3166-1 alpha-2 codes for the mapped countries and territories.
  /// Empty when no mapping is available.
  final List<String> countryIsoCodes;

  /// Entity labels from the ISO register or curated custom entry.
  final List<String> territories;

  /// ISO minor-unit exponent; null if unspecified or not applicable.
  final int? minorUnit;
  final CurrencyStatus status;

  /// ISO withdrawal date, preserving the source's year/month precision.
  final String? withdrawalDate;

  Currency({
    this.currencyName = 'Not defined',
    this.officialName,
    List<String> aliases = const [],
    required this.isoCode,
    this.currencySymbol,
    this.numericCode,
    this.territory,
    this.fractionalUnit,
    this.flag,
    this.countryIsoCode,
    List<String> countryIsoCodes = const [],
    List<String> territories = const [],
    this.minorUnit,
    this.status = CurrencyStatus.current,
    this.withdrawalDate,
  })  : countryIsoCodes = List.unmodifiable(countryIsoCodes),
        territories = List.unmodifiable(territories),
        aliases = List.unmodifiable(aliases);

  /// Three-digit ISO representation, including leading zeroes, e.g. 008.
  String? get numericCodeString => numericCode?.toString().padLeft(3, '0');

  /// Parses fields with [FormatException]s for invalid types or values.
  /// A missing/null name uses the constructor default; other metadata is optional.
  factory Currency.fromJson(Map<String, dynamic> json) {
    String? string(String key) {
      final value = json[key];
      if (value == null || value is String) return value as String?;
      throw FormatException('$key must be a string or null');
    }

    int? integer(String key, int maximum) {
      final value = json[key];
      if (value == null) return null;
      if (value is int && value >= 0 && value <= maximum) return value;
      throw FormatException('$key must be an integer from 0 to $maximum');
    }

    T enumeration<T extends Enum>(String key, List<T> values, T fallback) {
      final name = string(key);
      if (name == null) return fallback;
      for (final value in values) {
        if (value.name == name) return value;
      }
      throw FormatException('Unknown $key: $name');
    }

    final isoCode = string('isoCode');
    if (isoCode == null || !RegExp(r'^[A-Z]{3}$').hasMatch(isoCode)) {
      throw const FormatException('isoCode must be three uppercase letters');
    }
    final countryIsoCode = string('countryIsoCode');
    if (countryIsoCode != null &&
        !RegExp(r'^[A-Z]{2}$').hasMatch(countryIsoCode)) {
      throw const FormatException(
          'countryIsoCode must be two uppercase letters');
    }
    final countries = json['countryIsoCodes'];
    if (countries != null &&
        (countries is! List ||
            countries.any((value) =>
                value is! String || !RegExp(r'^[A-Z]{2}$').hasMatch(value)))) {
      throw const FormatException(
          'countryIsoCodes must be a list of two uppercase letter codes');
    }
    final status =
        enumeration('status', CurrencyStatus.values, CurrencyStatus.current);
    final entities = json['territories'];
    if (status == CurrencyStatus.nonIso && json['numericCode'] != null) {
      throw const FormatException(
          'numericCode must be null for a non-ISO entry');
    }
    if (entities != null &&
        (entities is! List || entities.any((entity) => entity is! String))) {
      throw const FormatException('territories must be a list of strings');
    }
    final aliases = json['aliases'];
    if (aliases != null &&
        (aliases is! List || aliases.any((alias) => alias is! String))) {
      throw const FormatException('aliases must be a list of strings');
    }
    return Currency(
      isoCode: isoCode,
      officialName: string('officialName'),
      aliases: aliases == null ? const [] : List<String>.from(aliases),
      currencyName: string('currencyName') ?? 'Not defined',
      currencySymbol: string('currencySymbol'),
      numericCode: integer('numericCode', 999),
      territory: string('territory'),
      fractionalUnit: string('fractionalUnit'),
      flag: string('flag'),
      countryIsoCode: countryIsoCode,
      countryIsoCodes:
          countries == null ? const [] : List<String>.from(countries),
      territories: entities == null ? const [] : List<String>.from(entities),
      minorUnit: integer('minorUnit', 9),
      status: status,
      withdrawalDate: string('withdrawalDate'),
    );
  }

  Map<String, dynamic> toJson() => {
        'isoCode': isoCode,
        'currencyName': currencyName,
        'officialName': officialName,
        'aliases': aliases,
        'numericCode': numericCode,
        'currencySymbol': currencySymbol,
        'territory': territory,
        'fractionalUnit': fractionalUnit,
        'flag': flag,
        'countryIsoCode': countryIsoCode,
        'countryIsoCodes': countryIsoCodes,
        'territories': territories,
        'minorUnit': minorUnit,
        'status': status.name,
        'withdrawalDate': withdrawalDate,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          currencyName == other.currencyName &&
          officialName == other.officialName &&
          aliases.length == other.aliases.length &&
          Iterable<int>.generate(aliases.length)
              .every((i) => aliases[i] == other.aliases[i]) &&
          isoCode == other.isoCode &&
          currencySymbol == other.currencySymbol &&
          numericCode == other.numericCode &&
          territory == other.territory &&
          fractionalUnit == other.fractionalUnit &&
          flag == other.flag &&
          countryIsoCode == other.countryIsoCode &&
          countryIsoCodes.length == other.countryIsoCodes.length &&
          Iterable<int>.generate(countryIsoCodes.length)
              .every((i) => countryIsoCodes[i] == other.countryIsoCodes[i]) &&
          minorUnit == other.minorUnit &&
          status == other.status &&
          withdrawalDate == other.withdrawalDate &&
          territories.length == other.territories.length &&
          Iterable<int>.generate(territories.length)
              .every((i) => territories[i] == other.territories[i]);

  @override
  int get hashCode => Object.hash(
        currencyName,
        officialName,
        Object.hashAll(aliases),
        isoCode,
        currencySymbol,
        numericCode,
        territory,
        fractionalUnit,
        flag,
        countryIsoCode,
        Object.hashAll(countryIsoCodes),
        minorUnit,
        status,
        withdrawalDate,
        Object.hashAll(territories),
      );

  @override
  String toString() => 'Currency($isoCode, $currencyName, ${status.name})';
}

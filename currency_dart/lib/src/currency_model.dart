/// Whether a code is current or retained for historical lookups.
enum CurrencyStatus { current, historical }

/// The kind of instrument represented by an ISO code.
enum CurrencyCategory { currency, fund, preciousMetal, special }

/// Immutable currency metadata. Null means unknown or not applicable.
class CurrencyModel {
  final String currencyName;
  final String? currencySymbol;
  final String isoCode;
  final int? numericCode;

  /// Display label retained for compatibility. Use [territories] for lists.
  final String? territory;

  /// Subdivision name, not a decimal precision.
  final String? fractionalUnit;

  /// Representative flag, not an exhaustive territory mapping.
  final String? flag;

  /// Entity names from the ISO register, without comma-based splitting.
  final List<String> territories;

  /// ISO minor-unit exponent; null if unspecified or not applicable.
  final int? minorUnit;
  final CurrencyStatus status;
  final CurrencyCategory category;

  /// ISO withdrawal date, preserving the source's year/month precision.
  final String? withdrawalDate;

  CurrencyModel({
    this.currencyName = 'Not defined',
    required this.isoCode,
    this.currencySymbol,
    this.numericCode,
    this.territory,
    this.fractionalUnit,
    this.flag,
    List<String> territories = const [],
    this.minorUnit,
    this.status = CurrencyStatus.current,
    this.category = CurrencyCategory.currency,
    this.withdrawalDate,
  }) : territories = List.unmodifiable(territories);

  /// Three-digit ISO representation, including leading zeroes, e.g. 008.
  String? get numericCodeString => numericCode?.toString().padLeft(3, '0');

  /// Parses fields with [FormatException]s for invalid types or values.
  /// A missing/null name uses the constructor default; other metadata is optional.
  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
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

    final code = string('isoCode');
    if (code == null || !RegExp(r'^[A-Z]{3}$').hasMatch(code)) {
      throw const FormatException('isoCode must be three uppercase letters');
    }
    final entities = json['territories'];
    if (entities != null &&
        (entities is! List || entities.any((entity) => entity is! String))) {
      throw const FormatException('territories must be a list of strings');
    }
    return CurrencyModel(
      isoCode: code,
      currencyName: string('currencyName') ?? 'Not defined',
      currencySymbol: string('currencySymbol'),
      numericCode: integer('numericCode', 999),
      territory: string('territory'),
      fractionalUnit: string('fractionalUnit'),
      flag: string('flag'),
      territories: entities == null ? const [] : List<String>.from(entities),
      minorUnit: integer('minorUnit', 9),
      status:
          enumeration('status', CurrencyStatus.values, CurrencyStatus.current),
      category: enumeration(
        'category',
        CurrencyCategory.values,
        CurrencyCategory.currency,
      ),
      withdrawalDate: string('withdrawalDate'),
    );
  }

  Map<String, dynamic> toJson() => {
        'isoCode': isoCode,
        'currencyName': currencyName,
        'numericCode': numericCode,
        'currencySymbol': currencySymbol,
        'territory': territory,
        'fractionalUnit': fractionalUnit,
        'flag': flag,
        'territories': territories,
        'minorUnit': minorUnit,
        'status': status.name,
        'category': category.name,
        'withdrawalDate': withdrawalDate,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyModel &&
          currencyName == other.currencyName &&
          isoCode == other.isoCode &&
          currencySymbol == other.currencySymbol &&
          numericCode == other.numericCode &&
          territory == other.territory &&
          fractionalUnit == other.fractionalUnit &&
          flag == other.flag &&
          minorUnit == other.minorUnit &&
          status == other.status &&
          category == other.category &&
          withdrawalDate == other.withdrawalDate &&
          territories.length == other.territories.length &&
          Iterable<int>.generate(territories.length)
              .every((i) => territories[i] == other.territories[i]);

  @override
  int get hashCode => Object.hash(
        currencyName,
        isoCode,
        currencySymbol,
        numericCode,
        territory,
        fractionalUnit,
        flag,
        minorUnit,
        status,
        category,
        withdrawalDate,
        Object.hashAll(territories),
      );

  @override
  String toString() => 'CurrencyModel($isoCode, $currencyName, ${status.name})';
}

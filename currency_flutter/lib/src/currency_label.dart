import 'package:currency_dart/currency_dart.dart';
import 'package:flutter/widgets.dart';

/// Displays a currency's code and name with an optional representative flag.
class CurrencyLabel extends StatelessWidget {
  const CurrencyLabel({
    super.key,
    required this.currency,
    this.showFlag = true,
    this.style,
  });

  final CurrencyModel currency;
  final bool showFlag;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final flag = currency.flag;
    final prefix = showFlag && flag != null && flag.isNotEmpty ? '$flag ' : '';
    return Text(
      '$prefix${currency.code} — ${currency.currencyName}',
      style: style,
      softWrap: true,
      semanticsLabel: '${currency.code}, ${currency.currencyName}',
    );
  }
}

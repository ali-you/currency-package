import 'package:currency_localization/currency_localization.dart';

void main() {
  const names = CurrencyLocalization();
  print(names.name('USD', locale: 'fa_IR'));
  print(names.name('EUR', locale: 'ar'));
  print(names.names(['USD', 'EUR', 'XAD'], locale: 'fa'));
}

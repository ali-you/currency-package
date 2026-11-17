import 'package:currency_dart/currency_dart.dart';
import 'package:flutter/material.dart';

/// Supplies a display name, for example from currency_localization.
typedef CurrencyNameBuilder = String Function(Currency currency);

/// A searchable currency list. Place in a parent with a bounded height.
///
/// Selection is controlled by [value]. Historical currencies are opt-in;
/// curated non-ISO currencies are included by default.
class CurrencyPicker extends StatefulWidget {
  const CurrencyPicker({
    super.key,
    required this.onChanged,
    this.value,
    this.historical = false,
    this.nonIso = true,
    this.showFlag = true,
    this.nameBuilder,
    this.searchHintText = 'Search currencies',
    this.emptyText = 'No currencies found',
    this.autofocus = false,
  });

  final ValueChanged<Currency> onChanged;
  final Currency? value;
  final bool historical;
  final bool nonIso;
  final bool showFlag;
  final CurrencyNameBuilder? nameBuilder;
  final String searchHintText;
  final String emptyText;
  final bool autofocus;

  @override
  State<CurrencyPicker> createState() => _CurrencyPickerState();
}

class _CurrencyPickerState extends State<CurrencyPicker> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final currencies = CurrencyRepository()
        .getAllCurrencies(historical: widget.historical, nonIso: widget.nonIso);
    final matches = <({Currency currency, String name})>[];
    for (final currency in currencies) {
      final name = widget.nameBuilder?.call(currency) ?? currency.currencyName;
      final terms = [
        currency.isoCode,
        name,
        currency.currencyName,
        currency.officialName,
        currency.currencySymbol,
        ...currency.aliases,
        ...currency.territories,
      ];
      if (query.isEmpty ||
          terms.any((term) => term?.toLowerCase().contains(query) ?? false)) {
        matches.add((currency: currency, name: name));
      }
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _search,
            autofocus: widget.autofocus,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: widget.searchHintText,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip:
                          MaterialLocalizations.of(context).deleteButtonTooltip,
                      onPressed: () => setState(_search.clear),
                      icon: const Icon(Icons.clear),
                    ),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: matches.isEmpty
              ? Center(child: Text(widget.emptyText))
              : ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final item = matches[index];
                    final currency = item.currency;
                    final selected = widget.value?.isoCode == currency.isoCode;
                    final flag = currency.flag;
                    return ListTile(
                      key: ValueKey(currency.isoCode),
                      leading: widget.showFlag && flag != null
                          ? ExcludeSemantics(child: Text(flag))
                          : null,
                      title: Text(item.name),
                      subtitle: Text([
                        currency.isoCode,
                        if (currency.currencySymbol != null)
                          currency.currencySymbol!,
                      ].join(' · ')),
                      selected: selected,
                      trailing: selected ? const Icon(Icons.check) : null,
                      onTap: () => widget.onChanged(currency),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Opens a searchable Material dialog and returns the selection, or null when
/// dismissed. Supply [nameBuilder] and text parameters for localized content.
Future<Currency?> showCurrencyPicker({
  required BuildContext context,
  Currency? value,
  bool historical = false,
  bool nonIso = true,
  bool showFlag = true,
  CurrencyNameBuilder? nameBuilder,
  String title = 'Select currency',
  String searchHintText = 'Search currencies',
  String emptyText = 'No currencies found',
}) =>
    showDialog<Currency>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          width: 400,
          height: 560,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child:
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
              ),
              Expanded(
                child: CurrencyPicker(
                  value: value,
                  historical: historical,
                  nonIso: nonIso,
                  showFlag: showFlag,
                  nameBuilder: nameBuilder,
                  searchHintText: searchHintText,
                  emptyText: emptyText,
                  onChanged: (currency) => Navigator.pop(context, currency),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                        MaterialLocalizations.of(context).cancelButtonLabel),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

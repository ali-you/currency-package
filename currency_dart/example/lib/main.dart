import 'package:currency_dart/currency_dart.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Currency browser',
        theme: ThemeData(useMaterial3: true),
        home: const MainScreen(),
      );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _currency = Currency();
  final _query = TextEditingController();
  bool _historical = false;
  bool _nonIso = true;
  List<CurrencyModel> get _currencies => _currency.getAllCurrencies(
        historical: _historical,
        nonIso: _nonIso,
      );

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _search() {
    final match = _currency.byCode(_query.text,
            historical: _historical, nonIso: _nonIso) ??
        _currency.byCurrencyName(_query.text,
            historical: _historical, nonIso: _nonIso);
    FocusScope.of(context).unfocus();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(match?.currencyName ?? 'Currency not found'),
        content: match == null
            ? const Text('Enter a currency code or an exact currency name. '
                'Use the currency code if a name is ambiguous.')
            : SingleChildScrollView(
                child: Text([
                  'Currency code: ${match.code}',
                  'Numeric code: ${match.numericCodeString ?? 'Unknown'}',
                  'Minor-unit exponent: ${match.minorUnit ?? 'Not applicable'}',
                  'Symbol: ${match.currencySymbol ?? 'Unknown'}',
                  'Territories: ${match.territory ?? 'Not applicable'}',
                ].join('\n')),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencies = _currencies;
    return Scaffold(
      appBar: AppBar(title: Text('Currencies (${currencies.length})')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _query,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  labelText: 'Currency code or name',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: 'Search currencies',
                    onPressed: _search,
                    icon: const Icon(Icons.search),
                  ),
                ),
              ),
            ),
            SwitchListTile(
              key: const Key('historical-filter'),
              dense: true,
              title: const Text('Show historical'),
              value: _historical,
              onChanged: (value) => setState(() => _historical = value),
            ),
            SwitchListTile(
              key: const Key('nonIso-filter'),
              dense: true,
              title: const Text('Show non-ISO'),
              value: _nonIso,
              onChanged: (value) => setState(() => _nonIso = value),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: currencies.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final currency = currencies[index];
                  return ListTile(
                    leading: Text(currency.flag ?? currency.code),
                    title: Text(currency.currencyName),
                    subtitle: Text(currency.code),
                    trailing: Text(currency.currencySymbol ?? ''),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

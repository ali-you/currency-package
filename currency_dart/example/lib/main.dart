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
  late final _currencies = _currency.getAllCurrencies(
    category: CurrencyCategory.currency,
  );

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _search() {
    final match = _currency.byIsoCode(_query.text) ??
        _currency.byCurrencyName(_query.text);
    FocusScope.of(context).unfocus();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(match?.currencyName ?? 'Currency not found'),
        content: match == null
            ? const Text('Enter a current ISO code or an exact currency name. '
                'Use the ISO code if a name is ambiguous.')
            : SingleChildScrollView(
                child: Text([
                  'ISO code: ${match.isoCode}',
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
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Current currencies')),
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
                    labelText: 'ISO code or currency name',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: 'Search currencies',
                      onPressed: _search,
                      icon: const Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: _currencies.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final currency = _currencies[index];
                    return ListTile(
                      leading: Text(currency.flag ?? currency.isoCode),
                      title: Text(currency.currencyName),
                      subtitle: Text(currency.isoCode),
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

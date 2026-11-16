import 'package:currency_localization/currency_localization.dart';
import 'package:test/test.dart';

void main() {
  const names = CurrencyLocalization();

  test('additional languages and regional datasets are available', () {
    expect(names.name('USD', locale: 'de'), 'US-Dollar');
    expect(names.name('USD', locale: 'fr'), 'dollar des États-Unis');
    expect(names.name('USD', locale: 'ja'), '米ドル');
    expect(
        names.name('USD', locale: 'pt-AO'), names.name('USD', locale: 'pt-PT'));
    expect(names.name('USD', locale: 'hi-Latn-XX'),
        names.name('USD', locale: 'hi-Latn'));
  });

  test('explicit script parents prevent falling into the wrong script', () {
    expect(names.lookup('UYW', locale: 'zh'), isNotNull);
    expect(names.lookup('UYW', locale: 'zh-Hant'), isNull);
    expect(
        names.name('UYW', locale: 'zh-Hant'), names.name('UYW', locale: 'en'));
  });

  test('returns CLDR display names in English, Persian and Arabic', () {
    expect(names.name('USD'), 'US Dollar');
    expect(names.name('USD', locale: 'fa'), 'دلار آمریکا');
    expect(names.name('USD', locale: 'ar'), 'دولار أمريكي');
    expect(names.name('EUR', locale: 'fa'), 'یورو');
    expect(names.name('PEN', locale: 'en'), 'Peruvian Sol');
  });

  test('normalizes ISO codes and locale tags', () {
    expect(names.name(' usd ', locale: ' FA_ir '), 'دلار آمریکا');
    expect(names.name('usd', locale: 'ar-EG'), 'دولار أمريكي');
    expect(names.name('USD', locale: 'fa-Arab-IR'), 'دلار آمریکا');
    expect(names.name('USD', locale: 'fa-IR-u-nu-arabext'), 'دلار آمریکا');
    expect(names.name('USD', locale: 'fa-x-private'), 'دلار آمریکا');
  });

  test('unsupported and malformed locales fall back to English', () {
    for (final locale in ['zz-ZZ', '', 'fa--IR', '@fa', 'x-private']) {
      expect(names.name('USD', locale: locale), 'US Dollar');
      expect(names.lookup('USD', locale: locale), isNull);
    }
  });

  test('missing names fall back per currency rather than just per locale', () {
    expect(names.supportsLocale('fa'), isTrue);
    expect(names.lookup('XDR', locale: 'fa'), isNull);
    expect(names.name('XDR', locale: 'fa'), names.lookup('XDR', locale: 'en'));
  });

  test('configured fallback precedes English but follows requested locale', () {
    const arabicFallback = CurrencyLocalization(fallbackLocale: 'ar-EG');
    expect(arabicFallback.name('USD', locale: 'zz'), 'دولار أمريكي');
    expect(arabicFallback.name('USD', locale: 'fa'), 'دلار آمریکا');
    expect(
        const CurrencyLocalization(fallbackLocale: 'unknown')
            .name('USD', locale: 'zz'),
        'US Dollar');
  });

  test('unknown and untranslated codes fall back to their normalized code', () {
    expect(names.name(' zzz ', locale: 'fa'), 'ZZZ');
    // XAD is in the ISO snapshot but absent from these CLDR datasets.
    expect(names.supportedCurrencyCodes, contains('XAD'));
    expect(names.lookup('XAD', locale: 'en'), isNull);
    expect(names.name('XAD', locale: 'fa'), 'XAD');
    expect(names.name('  ', locale: 'fa'), '');
  });

  test('supported locales describe bundled data, not fallback success', () {
    expect(names.supportedLocales.length, 657);
    expect(names.supportedLocales,
        containsAll(['en', 'fa', 'ar', 'de', 'fr', 'zh-hant']));
    expect(names.supportsLocale('FA_IR'), isTrue);
    expect(names.supportsLocale('zz'), isFalse);
    expect(names.supportsLocale(''), isFalse);
    expect(names.cldrVersion, '49.0.0');
  });

  test('collections are immutable and names maps normalize and deduplicate',
      () {
    final result = names.names([' usd ', 'USD', 'EUR', 'ZZZ'], locale: 'fa');
    expect(result, {'USD': 'دلار آمریکا', 'EUR': 'یورو', 'ZZZ': 'ZZZ'});
    expect(names.names([]), isEmpty);
    expect(() => result.clear(), throwsUnsupportedError);
    expect(() => names.supportedLocales.add('zz'), throwsUnsupportedError);
    expect(() => names.supportedCurrencyCodes.clear(), throwsUnsupportedError);
  });

  test('historical codes have localized names without changing their identity',
      () {
    expect(names.name('BYR', locale: 'en'), contains('2000'));
    expect(names.name('BYR', locale: 'en'),
        isNot(names.name('BYN', locale: 'en')));
  });
}

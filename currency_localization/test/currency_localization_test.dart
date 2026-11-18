import 'package:currency_localization/currency_localization.dart';
import 'package:test/test.dart';

void main() {
  const names = CurrencyLocalization();

  test(
      'project short codes resolve to the same translations as descriptive codes',
      () {
    const aliases = {
      'IRT': 'TOMAN',
      'SLS': 'SOMALILAND_SHILLING',
      'RUP': 'TRANSNISTRIAN_RUBLE',
      'IMP': 'MANX_POUND',
      'JEP': 'JERSEY_POUND',
      'GGP': 'GUERNSEY_POUND',
      'FOK': 'FAROESE_KRONA',
      'EUS': 'EUSKO',
      'CHI': 'CHIEMGAUER'
    };
    for (final entry in aliases.entries) {
      for (final locale in [
        'en',
        'fa',
        'ar',
        'zh',
        'zh-Hans-SG',
        'zh-Hant-HK',
        'yue',
        'zz'
      ]) {
        expect(names.name(' ${entry.key.toLowerCase()} ', locale: locale),
            names.name(entry.value, locale: locale));
      }
    }
  });

  test('custom currency names are localized with safe fallback', () {
    expect(names.supportedCurrencyCodes, contains('IRT'));
    expect(names.supportedCurrencyCodes, isNot(contains('TOMAN')));
    expect(names.name('TOMAN', locale: 'fa'), 'تومان ایران');
    expect(names.name('TOMAN', locale: 'ar'), 'تومان إيراني');
    for (final code in [
      'TOMAN',
      'SOMALILAND_SHILLING',
      'TRANSNISTRIAN_RUBLE',
      'MANX_POUND',
      'JERSEY_POUND',
      'GUERNSEY_POUND',
      'FAROESE_KRONA',
      'EUSKO',
      'CHIEMGAUER'
    ]) {
      expect(names.lookup(code, locale: 'en'), isNotNull);
      expect(names.lookup(code, locale: 'fa'), isNotNull);
      expect(names.lookup(code, locale: 'ar'), isNotNull);
      expect(names.name(code, locale: 'zz'), names.lookup(code, locale: 'en'));
    }
  });

  test('additional languages and regional datasets are available', () {
    expect(names.name('USD', locale: 'de'), 'US-Dollar');
    expect(names.name('USD', locale: 'fr'), 'dollar des États-Unis');
    expect(names.name('USD', locale: 'ja'), '米ドル');
    expect(
        names.name('USD', locale: 'pt-AO'), names.name('USD', locale: 'pt-PT'));
    expect(names.name('USD', locale: 'hi-Latn-XX'),
        names.name('USD', locale: 'hi-Latn'));
  });

  test('non-ISO currencies have native names in expanded language maps', () {
    const codes = [
      'CHI',
      'EUS',
      'FOK',
      'GGP',
      'IMP',
      'IRT',
      'JEP',
      'RUP',
      'SLS'
    ];
    for (final locale in [
      'zh',
      'zh-Hans',
      'zh-Hans-CN',
      'zh-Hans-SG',
      'zh-CN',
      'zh-Hant',
      'zh-Hant-HK',
      'zh-Hant-MO',
      'zh-TW',
      'yue',
      'yue-Hans',
      'yue-Hant',
      'yue-Hant-MO',
      'de',
      'fr',
      'es',
      'pt',
      'it',
      'ru',
      'ja',
      'ko',
      'hi',
      'tr',
      'nl',
      'pl',
      'uk',
      'id',
      'ms',
      'vi',
      'bn',
      'ur',
      ...names.supportedLocales.where(
          (locale) => locale.startsWith('zh') || locale.startsWith('yue')),
    ]) {
      for (final code in codes) {
        expect(names.lookup(code, locale: locale), isNotNull,
            reason: '$locale/$code should not need English fallback');
      }
    }
    expect(names.name('TOMAN', locale: 'zh'), '伊朗土曼');
    expect(names.name('IRT', locale: 'zh-Hant'), '伊朗土曼');
    expect(names.name('GGP', locale: 'zh-Hans-SG'), '根西镑');
    expect(names.name('GGP', locale: 'zh-Hant-HK'), '根西鎊');
    expect(names.name('GGP', locale: 'zh_TW'), '根西鎊');
    expect(names.name('GGP', locale: 'zh-HK'), '根西鎊');
    expect(names.name('GGP', locale: 'zh-MO'), '根西鎊');
    expect(names.name('GGP', locale: 'zh-CN'), '根西镑');
    expect(names.name('GGP', locale: 'zh-SG'), '根西镑');
    expect(names.name('RUP', locale: 'zh-Hans'), '德涅斯特河沿岸卢布');
    expect(names.name('RUP', locale: 'zh-Hant'), '德涅斯特河沿岸盧布');
  });

  test('explicit script parents prevent falling into the wrong script', () {
    expect(names.lookup('VED', locale: 'az'), isNotNull);
    expect(names.lookup('VED', locale: 'az-Cyrl'), isNull);
    expect(
        names.name('VED', locale: 'az-Cyrl'), names.name('VED', locale: 'en'));
  });

  test('additional non-ISO translations cover language and script variants',
      () {
    const codes = [
      'CHI',
      'EUS',
      'FOK',
      'GGP',
      'IMP',
      'IRT',
      'JEP',
      'RUP',
      'SLS'
    ];
    for (final locale in [
      'af',
      'bg',
      'bs',
      'ca',
      'cs',
      'da',
      'el',
      'eo',
      'et',
      'fi',
      'fil',
      'he',
      'hr',
      'hu',
      'is',
      'lt',
      'lv',
      'nb',
      'nn',
      'no',
      'ro',
      'sk',
      'sl',
      'sq',
      'sr',
      'sr-Latn',
      'sv',
      'sw',
      'gu',
      'mr',
      'ne',
      'pa',
      'kn',
      'ml',
      'ta',
      'te',
      'th',
      'ca-ES-valencia',
      'sr-Cyrl-BA',
      'sr-Latn-ME',
      'sw-KE',
      'pa-Guru',
      'nb-SJ',
      'ta-SG',
      'fil-PH',
    ]) {
      for (final code in codes) {
        expect(names.lookup(code, locale: locale), isNotNull,
            reason: '$locale/$code should not need English fallback');
      }
    }
    expect(names.name('IRT', locale: 'sr-Cyrl'), 'Ирански томан');
    expect(names.name('IRT', locale: 'sr-Latn'), 'Iranski toman');
    expect(names.name('TOMAN', locale: 'fr-CA'), 'toman iranien');
    expect(names.name('TOMAN', locale: 'es-AR'), 'tomán iraní');
    expect(names.name('TOMAN', locale: 'pt-AO'), 'toman iraniano');
  });

  test('returns localized display names in English, Persian and Arabic', () {
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
    expect(names.supportsLocale('az-Cyrl'), isTrue);
    expect(names.lookup('IRT', locale: 'az-Cyrl'), isNull);
    expect(names.name('IRT', locale: 'az-Cyrl'),
        names.lookup('IRT', locale: 'en'));
  });

  test('all currencies have native names in English, Persian and Arabic', () {
    for (final locale in ['en', 'fa', 'ar']) {
      for (final code in names.supportedCurrencyCodes) {
        expect(names.lookup(code, locale: locale), isNotNull,
            reason: '$locale/$code');
      }
    }
    expect(names.lookup('SVC', locale: 'fa-IR'), 'کولون السالوادور');
    expect(names.lookup('SVC', locale: 'hi-IN'), 'साल्वाडोरन कोलोन');
    expect(names.lookup('VED', locale: 'fa'), 'بولیوار ونزوئلا');
    expect(names.lookup('VED', locale: 'ar'), 'بوليفار فنزويلي');
    expect(names.lookup('VED', locale: 'zh-Hant'), isNotNull);
  });

  test('every supported locale resolves every currency to a display name', () {
    for (final locale in names.supportedLocales) {
      for (final code in names.supportedCurrencyCodes) {
        expect(names.name(code, locale: locale), isNot(code),
            reason: '$locale/$code');
        // Unknown locales must still honor a caller's configured fallback.
        if (names.lookup(code, locale: locale) == null) {
          expect(
              const CurrencyLocalization(fallbackLocale: 'fa')
                  .name(code, locale: locale),
              names.lookup(code, locale: 'fa'),
              reason: '$locale/$code');
        }
      }
    }
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
    // Removed fund codes are not supported currencies.
    expect(names.supportedCurrencyCodes, isNot(contains('XAD')));
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

import 'package:intl_usage/intl_usage.dart';
import 'package:test/test.dart';

void main() {
  group('TranslationsUtil', () {
    late TranslationsUtil translationsUtil;

    setUp(() {
      translationsUtil = TranslationsUtil();
    });

    test('findMissingKeys identifies missing keys correctly', () {
      List<TranslationEntry> translations = [
        TranslationEntry(key: 'greeting', locales: {'en', 'es'}),
        TranslationEntry(key: 'farewell', locales: {'en'}),
        TranslationEntry(key: 'welcome', locales: {'en', 'es', 'fr'}),
      ];

      Map<String, List<String>> expectedMissingKeys = {
        'fr': ['greeting', 'farewell'],
        'es': ['farewell'],
      };

      Map<String, List<String>> actualMissingKeys =
          translationsUtil.findMissingKeys(translations);

      expect(actualMissingKeys, expectedMissingKeys);
    });
  });
}

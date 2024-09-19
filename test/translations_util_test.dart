import 'dart:io';

import 'package:intl_usage/intl_usage.dart';
import 'package:intl_usage/src/file_system/application/file_system_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockFileSystemUtils extends Mock implements FileSystemUtils {}

class MockFile extends Mock implements File {}

void main() {
  group('TranslationsUtils', () {
    late TranslationsUtil translationsUtils;
    late MockFileSystemUtils mockFileSystemUtils;
    late MockFile mockFileEn;
    late MockFile mockFileDe;

    setUp(() {
      translationsUtils = TranslationsUtil();
      mockFileSystemUtils = MockFileSystemUtils();
      mockFileEn = MockFile();
      mockFileDe = MockFile();
    });
    group('getTranslations', () {
      test(
          'Given valid JSON translation files, '
          'When getTranslations is called, '
          'Then it should extract translations with correct keys and locales',
          () async {
        // Arrange
        when(() => mockFileSystemUtils.searchForFiles(
              relativePath: any(named: 'relativePath'),
              extension: any(named: 'extension'),
            )).thenAnswer((_) async => [mockFileEn, mockFileDe]);
        when(() => mockFileEn.path).thenReturn('assets/translations/en.json');
        when(() => mockFileDe.path).thenReturn('assets/translations/de.json');
        when(() => mockFileEn.readAsStringSync()).thenAnswer((_) => '''
        {
          "home": {
            "title": "Home Title",
            "subtitle": "Home Subtitle"
          }
        }
      ''');
        when(() => mockFileDe.readAsStringSync()).thenAnswer((_) => '''
        {
          "home": {
            "title": "Startseite Titel"
          }
        }
      '''); // Act
        List<TranslationEntry> translations =
            await translationsUtils.getTranslations(
          'assets/translations',
          fileSystemUtils: mockFileSystemUtils,
        );

        // Assert
        expect(translations, hasLength(2));
        expect(
          translations,
          contains(TranslationEntry(key: 'home.title', locales: {'en', 'de'})),
        );
        expect(
          translations,
          contains(TranslationEntry(key: 'home.subtitle', locales: {'en'})),
        );
      });

      test(
          'Given a JSON translation file with invalid format, '
          'When getTranslations is called, '
          'Then it should skip the invalid file and continue processing',
          () async {
        // Arrange
        when(() => mockFileSystemUtils.searchForFiles(
              relativePath: any(named: 'relativePath'),
              extension: any(named: 'extension'),
            )).thenAnswer((_) async => [mockFileEn]);
        when(() => mockFileEn.path).thenReturn('assets/translations/en.json');
        when(() => mockFileEn.readAsStringSync()).thenAnswer((_) => '''
        {
          "home": {
            "title": "Home Title",
          "subtitle": 
        }
      '''); // Invalid JSON format

        // Act
        List<TranslationEntry> translations =
            await translationsUtils.getTranslations(
          'assets/translations',
          fileSystemUtils: mockFileSystemUtils,
        );

        // Assert
        expect(translations, isEmpty); // No translations should be extracted
      });

      test(
          'Given a file that does not match the locale pattern, '
          'When getTranslations is called, '
          'Then it should skip the file', () async {
        // Arrange
        when(() => mockFileSystemUtils.searchForFiles(
              relativePath: any(named: 'relativePath'),
              extension: any(named: 'extension'),
            )).thenAnswer((_) async => [mockFileEn]);
        when(() => mockFileEn.path).thenReturn(
            'assets/translations/invalid_file.json'); // Invalid file name
        when(() => mockFileEn.readAsStringSync()).thenAnswer((_) => '''
        {
          "home": {
            "title": "Home Title"
          }
        }
      ''');

        // Act
        List<TranslationEntry> translations =
            await translationsUtils.getTranslations(
          'assets/translations',
          fileSystemUtils: mockFileSystemUtils,
        );

        // Assert
        expect(translations, isEmpty); // No translations should be extracted
      });
    });

    group('findMissingKeys', () {
      test(
          'Given a list of translation entries, '
          'When findMissingKeys is called, '
          'Then it should return a map of missing keys for each locale',
          () async {
        // Arrange
        List<TranslationEntry> translations = [
          TranslationEntry(key: 'home.title', locales: {'en', 'de'}),
          TranslationEntry(key: 'home.subtitle', locales: {'en'}),
          TranslationEntry(key: 'settings.title', locales: {'de'}),
        ];

        // Act
        Map<String, List<String>> missingKeys =
            translationsUtils.findMissingKeys(translations);

        // Assert
        expect(missingKeys, hasLength(2));
        expect(missingKeys['de'], ['home.subtitle']);
        expect(missingKeys['en'], ['settings.title']);
      });

      test(
          'Given a list of translation entries where all keys exist in all locales, '
          'When findMissingKeys is called, '
          'Then it should return an empty map', () async {
        // Arrange
        List<TranslationEntry> translations = [
          TranslationEntry(key: 'home.title', locales: {'en', 'de'}),
          TranslationEntry(key: 'home.subtitle', locales: {'en', 'de'}),
        ];

        // Act
        Map<String, List<String>> missingKeys =
            translationsUtils.findMissingKeys(translations);

        // Assert
        expect(missingKeys, isEmpty);
      });
    });
  });
}

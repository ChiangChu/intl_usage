import 'dart:io';

import 'package:intl_usage/intl_usage.dart';
import 'package:intl_usage/src/file_system/application/file_system_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockFileSystemUtils extends Mock implements FileSystemUtils {}

class MockFile extends Mock implements File {}

void main() {
  group('UsagesUtils', () {
    late UsagesUtils usagesUtils;
    late MockFileSystemUtils mockFileSystemUtils;
    late MockFile mockFile;

    setUp(() {
      usagesUtils = UsagesUtils();
      mockFileSystemUtils = MockFileSystemUtils();
      mockFile = MockFile();
    });

    group('getUsages', () {
      test(
          'Given a list of translation entries and Dart files containing their usages, '
          'When getUsages is called, '
          'Then it should return a map with usage entries for each translation key',
          () async {
        // Arrange
        when(() => mockFileSystemUtils.searchForFiles(
              relativePath: any(named: 'relativePath'),
              extension: any(named: 'extension'),
            )).thenAnswer((_) async => [mockFile]);
        when(() => mockFile.path).thenReturn('lib/main.dart');
        when(() => mockFile.readAsLines()).thenAnswer((_) async => [
              "import 'package:easy_localization/easy_localization.dart';",
              "Text('home.title'.tr());",
              "Text('settings.name'.tr());",
            ]);
        List<TranslationEntry> entries = [
          TranslationEntry(key: 'home.title', locales: {'en'}),
          TranslationEntry(key: 'settings.name', locales: {'en'}),
        ];

        // Act
        Map<String, Set<UsageEntry>> usages = await usagesUtils.getUsages(
          entries,
          fileSystemUtils: mockFileSystemUtils,
        );

        // Assert
        expect(usages, hasLength(2));
        expect(usages['home.title'], isNotEmpty);
        expect(usages['home.title']!.first.filename, 'lib/main.dart');
        expect(usages['home.title']!.first.line, 2);
        expect(usages['settings.name'], isNotEmpty);
        expect(usages['settings.name']!.first.filename, 'lib/main.dart');
        expect(usages['settings.name']!.first.line, 3);
      });

      test(
          'Given no usages of translation keys in Dart files, '
          'When getUsages is called, '
          'Then it should return an empty map for the corresponding key',
          () async {
        // Arrange
        when(() => mockFileSystemUtils.searchForFiles(
              relativePath: any(named: 'relativePath'),
              extension: any(named: 'extension'),
            )).thenAnswer((_) async => [mockFile]);
        when(() => mockFile.path).thenReturn('lib/main.dart');
        when(() => mockFile.readAsLines()).thenAnswer((_) async => [
              "Text('other.key'.tr());",
            ]);
        List<TranslationEntry> entries = [
          TranslationEntry(key: 'home.title', locales: {'en'}),
        ];

        // Act
        Map<String, Set<UsageEntry>> usages = await usagesUtils.getUsages(
          entries,
          fileSystemUtils: mockFileSystemUtils,
        );

        // Assert
        expect(usages['home.title'], isEmpty);
      });

      test(
          'Given a translation key with underscore in a Dart file, '
          'When getUsages is called, '
          'Then it should identify the usage as a full match', () async {
        // Arrange
        when(() => mockFileSystemUtils.searchForFiles(
              relativePath: any(named: 'relativePath'),
              extension: any(named: 'extension'),
            )).thenAnswer((_) async => [mockFile]);
        when(() => mockFile.path).thenReturn('lib/main.dart');
        when(() => mockFile.readAsLines()).thenAnswer((_) async => [
              "Text('home.sub_title'.tr());",
            ]);
        List<TranslationEntry> entries = [
          TranslationEntry(key: 'home.sub_title', locales: {'en'}),
        ];

        // Act
        Map<String, Set<UsageEntry>> usages = await usagesUtils.getUsages(
          entries,
          fileSystemUtils: mockFileSystemUtils,
        );

        // Assert
        expect(usages['home.sub_title'], isNotEmpty);
        expect(usages['home.sub_title']!.first.isUnsure, isFalse);
      });

      test(
          'Given a translation key with hyphens in a Dart file, '
          'When getUsages is called, '
          'Then it should identify the usage as a full match', () async {
        // Arrange
        when(() => mockFileSystemUtils.searchForFiles(
              relativePath: any(named: 'relativePath'),
              extension: any(named: 'extension'),
            )).thenAnswer((_) async => [mockFile]);
        when(() => mockFile.path).thenReturn('lib/main.dart');
        when(() => mockFile.readAsLines()).thenAnswer((_) async => [
              "Text('home.sub-title'.tr());",
            ]);
        List<TranslationEntry> entries = [
          TranslationEntry(key: 'home.sub-title', locales: {'en'}),
        ];

        // Act
        Map<String, Set<UsageEntry>> usages = await usagesUtils.getUsages(
          entries,
          fileSystemUtils: mockFileSystemUtils,
        );

        // Assert
        expect(usages['home.sub-title'], isNotEmpty);
        expect(usages['home.sub-title']!.first.isUnsure, isFalse);
      });

      test(
          'Given a translation key with string interpolation at the end '
          'When getUsages is called, '
          'Then it should flag as unsure.', () async {
        // Arrange
        when(() => mockFileSystemUtils.searchForFiles(
              relativePath: any(named: 'relativePath'),
              extension: any(named: 'extension'),
            )).thenAnswer((_) async => [mockFile]);
        when(() => mockFile.path).thenReturn('lib/main.dart');
        when(() => mockFile.readAsLines()).thenAnswer((_) async => [
              r"Text('simple.enum.${StatusEnum.active}'.tr());",
              r"Text('settings.name.$state'.tr());",
            ]);
        List<TranslationEntry> entries = [
          TranslationEntry(key: 'simple.enum.active', locales: {'en'}),
          TranslationEntry(key: 'settings.name.inactive', locales: {'en'}),
        ];

        // Act
        Map<String, Set<UsageEntry>> usages = await usagesUtils.getUsages(
          entries,
          fileSystemUtils: mockFileSystemUtils,
          debug: true,
        );

        // Assert
        expect(usages['simple.enum.active'], isNotEmpty);
        expect(usages['settings.name.inactive'], isNotEmpty);
        expect(
          usages['simple.enum.active']!.first.isUnsure,
          isTrue,
        );
        expect(
          usages['settings.name.inactive']!.first.isUnsure,
          isTrue,
        );
      });

      test(
          'Given a translation key with string interpolation is not at the end '
          'When getUsages is called, '
          'Then it should flag as unsure.', () async {
        // Arrange
        when(() => mockFileSystemUtils.searchForFiles(
              relativePath: any(named: 'relativePath'),
              extension: any(named: 'extension'),
            )).thenAnswer((_) async => [mockFile]);
        when(() => mockFile.path).thenReturn('lib/main.dart');
        when(() => mockFile.readAsLines()).thenAnswer((_) async => [
              r"Text('simple.enum.${StatusEnum.active}.another'.tr());",
              r"Text('settings.name.$state.another'.tr());",
            ]);
        List<TranslationEntry> entries = [
          TranslationEntry(key: 'simple.enum.active.another', locales: {'en'}),
          TranslationEntry(
              key: 'settings.name.inactive.another', locales: {'en'}),
        ];

        // Act
        Map<String, Set<UsageEntry>> usages = await usagesUtils.getUsages(
          entries,
          fileSystemUtils: mockFileSystemUtils,
        );

        // Assert
        expect(usages['simple.enum.active.another'], isNotEmpty);
        expect(usages['settings.name.inactive.another'], isNotEmpty);
        expect(
          usages['simple.enum.active.another']!.first.isUnsure,
          isTrue,
        );
        expect(
          usages['settings.name.inactive.another']!.first.isUnsure,
          isTrue,
        );
      });
    });
  });
}

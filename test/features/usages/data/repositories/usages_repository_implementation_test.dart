import 'package:intl_usage/src/core/domain/entities/project_file.dart';
import 'package:intl_usage/src/core/domain/repositories/file_system_repository_interface.dart';
import 'package:intl_usage/src/features/usages/data/repositories/usages_repository_implementation.dart';
import 'package:intl_usage/src/features/usages/data/services/translation_key_matcher.dart';
import 'package:intl_usage/src/features/usages/domain/entities/usage_entry.dart';
import 'package:intl_usage/src/features/usages/domain/repositories/usages_repository_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockFileSystemRepository extends Mock implements IFileSystemRepository {}

void main() {
  late IUsagesRepository sut;
  late MockFileSystemRepository mockFileSystem;

  setUp(() {
    mockFileSystem = MockFileSystemRepository();
    sut = UsagesRepositoryImpl(mockFileSystem, TranslationKeyMatcher());
  });

  void givenDartFiles(List<ProjectFile> files) {
    when(
      () => mockFileSystem.findFilesByExtension('.dart'),
    ).thenAnswer((_) async => files);
  }

  group('UsagesRepositoryImpl', () {
    group('findUsages', () {
      group('full match', () {
        test(
          '''
          GIVEN a dart file contains the translation key in single quotes
          WHEN findUsages is called
          THEN it returns one entry with isUnsure false at the correct location
          ''',
          () async {
            // GIVEN
            givenDartFiles(<ProjectFile>[
              ProjectFile(
                path: 'lib/home.dart',
                content: "final title = tr('greeting.title');",
              ),
            ]);

            // WHEN
            final Map<String, Set<UsageEntry>> result =
                await sut.findUsages(<String>['greeting.title']);

            // THEN
            final Set<UsageEntry> entries = result['greeting.title']!;
            expect(entries.length, 1);
            expect(entries.first.filename, 'lib/home.dart');
            expect(entries.first.line, 1);
            expect(entries.first.isUnsure, isFalse);
          },
        );
        test(
          '''
          GIVEN a dart file contains the translation key in double quotes
          WHEN findUsages is called
          THEN it returns one entry with isUnsure false
          ''',
          () async {
            // GIVEN
            givenDartFiles(<ProjectFile>[
              ProjectFile(
                path: 'lib/home.dart',
                content: 'final title = tr("greeting.title");',
              ),
            ]);

            // WHEN
            final Map<String, Set<UsageEntry>> result =
                await sut.findUsages(<String>['greeting.title']);

            // THEN
            final Set<UsageEntry> entries = result['greeting.title']!;
            expect(entries.length, 1);
            expect(entries.first.isUnsure, isFalse);
          },
        );
        test(
          '''
          GIVEN the translation key appears in multiple dart files
          WHEN findUsages is called
          THEN it returns one entry per file each with isUnsure false
          ''',
          () async {
            // GIVEN
            givenDartFiles(<ProjectFile>[
              ProjectFile(
                path: 'lib/screen_a.dart',
                content: "tr('greeting.title')",
              ),
              ProjectFile(
                path: 'lib/screen_b.dart',
                content: "tr('greeting.title')",
              ),
            ]);

            // WHEN
            final Map<String, Set<UsageEntry>> result =
                await sut.findUsages(<String>['greeting.title']);

            // THEN
            final Set<UsageEntry> entries = result['greeting.title']!;
            expect(entries.length, 2);
            expect(
              entries.every((UsageEntry e) => !e.isUnsure),
              isTrue,
            );
          },
        );
        test(
          '''
          GIVEN the translation key appears on multiple lines in the same file
          WHEN findUsages is called
          THEN it returns one entry per matching line
          ''',
          () async {
            // GIVEN
            givenDartFiles(<ProjectFile>[
              ProjectFile(
                path: 'lib/home.dart',
                content: "tr('greeting.title')\ntr('greeting.title')",
              ),
            ]);

            // WHEN
            final Map<String, Set<UsageEntry>> result =
                await sut.findUsages(<String>['greeting.title']);

            // THEN
            expect(result['greeting.title']!.length, 2);
          },
        );
      });

      group('partial match (unsure)', () {
        test(
          '''
          GIVEN a dart file contains only the key prefix without the full path
          WHEN findUsages is called with the full key
          THEN it returns one entry with isUnsure true
          ''',
          () async {
            // GIVEN
            givenDartFiles(<ProjectFile>[
              ProjectFile(
                path: 'lib/home.dart',
                content: "tr('greeting')",
              ),
            ]);

            // WHEN
            final Map<String, Set<UsageEntry>> result =
                await sut.findUsages(<String>['greeting.title']);

            // THEN
            final Set<UsageEntry> entries = result['greeting.title']!;
            expect(entries.length, 1);
            expect(entries.first.isUnsure, isTrue);
          },
        );
        test(
          '''
          GIVEN a dart file uses a dynamic \$variable segment in the translation key
          WHEN findUsages is called
          THEN it returns one entry with isUnsure true
          ''',
          () async {
            // GIVEN - dart code resolves gender at runtime: 'greeting.$gender.title'
            givenDartFiles(<ProjectFile>[
              ProjectFile(
                path: 'lib/home.dart',
                content: r"tr('greeting.$gender.title')",
              ),
            ]);

            // WHEN
            final Map<String, Set<UsageEntry>> result =
                await sut.findUsages(<String>['greeting.he.title']);

            // THEN
            final Set<UsageEntry> entries = result['greeting.he.title']!;
            expect(entries.length, 1);
            expect(entries.first.isUnsure, isTrue);
          },
        );
        test(
          '''
          GIVEN a dart file uses a complex \${expression} segment in the translation key
          WHEN findUsages is called
          THEN it returns one entry with isUnsure true
          ''',
          () async {
            // GIVEN - dart code resolves gender via object property at runtime
            givenDartFiles(<ProjectFile>[
              ProjectFile(
                path: 'lib/home.dart',
                content: r"tr('greeting.${user.gender}.title')",
              ),
            ]);

            // WHEN
            final Map<String, Set<UsageEntry>> result =
                await sut.findUsages(<String>['greeting.he.title']);

            // THEN
            final Set<UsageEntry> entries = result['greeting.he.title']!;
            expect(entries.length, 1);
            expect(entries.first.isUnsure, isTrue);
          },
        );
      });

      group('no match', () {
        test(
          '''
          GIVEN no dart file contains the translation key
          WHEN findUsages is called
          THEN it returns an empty set for that key
          ''',
          () async {
            // GIVEN
            givenDartFiles(<ProjectFile>[
              ProjectFile(
                path: 'lib/home.dart',
                content: "tr('other.key')",
              ),
            ]);

            // WHEN
            final Map<String, Set<UsageEntry>> result =
                await sut.findUsages(<String>['greeting.title']);

            // THEN
            expect(result['greeting.title']!, isEmpty);
          },
        );
        test(
          '''
          GIVEN there are no dart files in the project
          WHEN findUsages is called
          THEN it returns an empty set for every requested key
          ''',
          () async {
            // GIVEN
            givenDartFiles(<ProjectFile>[]);

            // WHEN
            final Map<String, Set<UsageEntry>> result = await sut.findUsages(
              <String>['greeting.title', 'general.ok'],
            );

            // THEN
            expect(result['greeting.title']!, isEmpty);
            expect(result['general.ok']!, isEmpty);
          },
        );
      });

      group('mixed results', () {
        test(
          '''
          GIVEN files with a full match, a prefix-only partial match, and a missing key
          WHEN findUsages is called
          THEN each key is categorized with the correct match type
          ''',
          () async {
            // GIVEN
            givenDartFiles(<ProjectFile>[
              ProjectFile(
                path: 'lib/home.dart',
                content: "tr('greeting.title')",
              ),
              ProjectFile(
                path: 'lib/profile.dart',
                content: "tr('greeting')",
              ),
            ]);

            // WHEN
            final Map<String, Set<UsageEntry>> result = await sut.findUsages(
              <String>['greeting.title', 'key.not.found'],
            );

            // THEN
            final Set<UsageEntry> greetingEntries = result['greeting.title']!;
            expect(greetingEntries.length, 2);

            final UsageEntry fullMatch = greetingEntries.firstWhere(
              (UsageEntry e) => e.filename == 'lib/home.dart',
            );
            expect(fullMatch.isUnsure, isFalse);

            final UsageEntry partialMatch = greetingEntries.firstWhere(
              (UsageEntry e) => e.filename == 'lib/profile.dart',
            );
            expect(partialMatch.isUnsure, isTrue);

            expect(result['key.not.found']!, isEmpty);
          },
        );
      });
    });
  });
}

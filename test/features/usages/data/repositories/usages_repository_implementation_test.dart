import 'package:intl_usage/src/core/domain/entities/project_file.dart';
import 'package:intl_usage/src/core/domain/repositories/file_system_repository_interface.dart';
import 'package:intl_usage/src/features/usages/data/repositories/usages_repository_implementation.dart';
import 'package:intl_usage/src/features/usages/domain/entities/usage_entry.dart';
import 'package:intl_usage/src/features/usages/domain/repositories/usages_repository_interface.dart';
import 'package:intl_usage/src/features/usages/data/services/translation_key_matcher.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class FakeFileSystemRepository extends Mock implements IFileSystemRepository {
  @override
  Future<List<ProjectFile>> findFilesByExtension(String extension) async {
    if (extension != '.dart') {
      return <ProjectFile>[];
    }
    return <ProjectFile>[
      ProjectFile(
        path: 'lib/src/home_screen.dart',
        content: '''
// Line 1
final title = translate('greeting.title'); // Full hit.
final button = translate("general.ok");
''',
      ),
      ProjectFile(
        path: 'lib/src/profile_view.dart',
        content: '''
// Line 1
// Line 2
final header = translate('greeting'); // Partial hit
''',
      ),
      ProjectFile(
        path: 'lib/src/utils.dart',
        content: 'final unrelated = "some_string";',
      ),
    ];
  }
}

void main() {
  late IUsagesRepository usagesRepository;
  late IFileSystemRepository fakeFileSystemRepository;

  setUp(() {
    fakeFileSystemRepository = FakeFileSystemRepository();
    usagesRepository = UsagesRepositoryImpl(
      fakeFileSystemRepository,
      TranslationKeyMatcher(),
    );
  });

  group('UsagesRepositoryImpl', () {
    group('findUsages', () {
      test(
        '''
      GIVEN a file system with Dart files containing various translation key usages
      WHEN findUsages is called with a list of keys
      THEN it should return a map correctly identifying full, unsure, and missing usages
      ''',
        () async {
          // GIVEN
          final List<String> keysToFind = <String>[
            'greeting.title',
            'general.ok',
            'key.not.found',
          ];

          // WHEN
          final Map<String, Set<UsageEntry>> usages =
              await usagesRepository.findUsages(keysToFind);

          // THEN
          expect(usages.keys.length, 3);

          final Set<UsageEntry> greetingUsages = usages['greeting.title']!;
          expect(greetingUsages.length, 2);

          final UsageEntry fullGreetingMatch = greetingUsages.firstWhere(
            (UsageEntry u) => u.filename == 'lib/src/home_screen.dart',
          );
          expect(fullGreetingMatch.line, 2);
          expect(fullGreetingMatch.isUnsure, isFalse);

          final UsageEntry partialGreetingMatch = greetingUsages.firstWhere(
            (UsageEntry u) => u.filename == 'lib/src/profile_view.dart',
          );
          expect(partialGreetingMatch.line, 3);
          expect(partialGreetingMatch.isUnsure, isTrue);

          final Set<UsageEntry> generalOkUsages = usages['general.ok']!;
          expect(generalOkUsages.length, 1);
          final UsageEntry generalOkMatch = generalOkUsages.first;
          expect(generalOkMatch.filename, 'lib/src/home_screen.dart');
          expect(generalOkMatch.line, 3);
          expect(generalOkMatch.isUnsure, isFalse);

          final Set<UsageEntry> notFoundUsages = usages['key.not.found']!;
          expect(notFoundUsages, isEmpty);
        },
      );
    });
  });
}

import 'package:intl_usage/src/features/translations/domain/entities/translation_entry.dart';
import 'package:intl_usage/src/features/usages/application/usages_service.dart';
import 'package:intl_usage/src/features/usages/domain/entities/usage_entry.dart';
import 'package:intl_usage/src/features/usages/domain/repositories/usages_repository_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockUsagesRepository extends Mock implements IUsagesRepository {}

void main() {
  late UsagesService usagesService;
  late IUsagesRepository mockUsagesRepository;

  setUp(() {
    mockUsagesRepository = MockUsagesRepository();
    usagesService = UsagesService(mockUsagesRepository);
  });

  group('UsagesService', () {
    test(
      '''
      GIVEN a list of translation entries
      WHEN findUsagesFor is called
      THEN it should call the repository with the correct keys and return the result
      ''',
      () async {
        // GIVEN
        final List<TranslationEntry> testEntries = <TranslationEntry>[
          TranslationEntry(key: 'key1', locales: <String>{'en'}),
          TranslationEntry(key: 'key2', locales: <String>{'en', 'de'}),
        ];
        final List<String> expectedKeys = <String>['key1', 'key2'];

        final Map<String, Set<UsageEntry>> repositoryResult =
            <String, Set<UsageEntry>>{
          'key1': <UsageEntry>{
            UsageEntry(filename: 'file.dart', line: 1, isUnsure: false),
          },
          'key2': <UsageEntry>{},
        };

        when(() => mockUsagesRepository.findUsages(expectedKeys))
            .thenAnswer((_) async => repositoryResult);

        // WHEN
        final Map<String, Set<UsageEntry>> result =
            await usagesService.findUsagesFor(testEntries);

        // THEN
        expect(result, repositoryResult);
        verify(() => mockUsagesRepository.findUsages(expectedKeys)).called(1);
        verifyNoMoreInteractions(mockUsagesRepository);
      },
    );
  });
}

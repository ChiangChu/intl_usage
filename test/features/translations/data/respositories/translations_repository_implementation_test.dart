import 'package:intl_usage/src/core/domain/entities/project_file.dart';
import 'package:intl_usage/src/core/domain/repositories/file_system_repository_interface.dart';
import 'package:intl_usage/src/features/translations/data/repositories/translations_repository_implementation.dart';
import 'package:intl_usage/src/features/translations/domain/entities/raw_translation.dart';
import 'package:intl_usage/src/features/translations/domain/repositories/translations_repository_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class FakeSystemRepository extends Mock implements IFileSystemRepository {}

void main() {
  late ITranslationsRepository translationsRepository;
  late IFileSystemRepository fakeFileSystemRepository;

  setUp(() {
    fakeFileSystemRepository = FakeSystemRepository();
    translationsRepository =
        TranslationsRepositoryImpl(fakeFileSystemRepository);
  });

  group('TranslationsRepositoryImpl', () {
    group('getTranslationsFromPath', () {
      test(
        '''
      GIVEN a file system containing a mix of valid and invalid translation files
      WHEN getTranslationsFromPath is called with specific base path
      THEN it should only process validly named JSON files within that path
      and correctly parse their content into RawTranslation objects
      ''',
        () async {
          // GIVEN
          when(() => fakeFileSystemRepository.findFilesByExtension('.json'))
              .thenAnswer(
            (_) => Future<List<ProjectFile>>.value(
              <ProjectFile>[
                ProjectFile(
                  path: 'assets/l10n/en.json',
                  content:
                      '{"greeting": "Hello", "nested": {"value": "World"}}',
                ),
                ProjectFile(
                  path: 'assets/l10n/de-DE.json',
                  content: '{"greeting": "Hallo"}',
                ),
                ProjectFile(
                  path: 'assets/l10n/english.json',
                  content: '{"message": "ignore me"}',
                ),
                ProjectFile(
                  path: 'assets/l10n/app.json',
                  content: '{"config": "some value"}',
                ),
              ],
            ),
          );

          // WHEN
          final List<RawTranslation> result = await translationsRepository
              .getTranslationsFromPath('assets/l10n');

          // THEN
          expect(result.length, 2);

          final RawTranslation enTranslation =
              result.firstWhere((RawTranslation e) => e.locale == 'en');
          expect(enTranslation.locale, 'en');
          expect(enTranslation.translations, hasLength(2));
          expect(enTranslation.translations['nested.value'], 'World');

          final RawTranslation deTranslation =
              result.firstWhere((RawTranslation e) => e.locale == 'de-DE');

          expect(deTranslation.locale, 'de-DE');
          expect(deTranslation.translations, hasLength(1));
          expect(deTranslation.translations['greeting'], 'Hallo');
        },
      );
    });
  });
}

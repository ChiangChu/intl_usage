import 'package:intl_usage/src/features/translations/domain/entities/raw_translation.dart';
import 'package:intl_usage/src/features/translations/domain/entities/translation_entry.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:intl_usage/src/features/translations/application/translations_service.dart';
import 'package:intl_usage/src/features/translations/domain/repositories/translations_repository_interface.dart';

class FakeTranslationsRepository extends Mock
    implements ITranslationsRepository {}

void main() {
  late TranslationsService translationsService;
  late ITranslationsRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeTranslationsRepository();
    translationsService = TranslationsService(fakeRepository);
  });

  group('TranslationsService', () {
    group('getAggregatedTranslations', () {
      test('''
      GIVEN a set of raw translations from different locales
      WHEN getAggregatedTranslations is called
      THEN it should return a single list of translations entries with locales correctly merged
      ''', () async {
        // GIVEN
        when(() => fakeRepository.getTranslationsFromPath('any/path'))
            .thenAnswer(
          (_) => Future<List<RawTranslation>>.value(
            <RawTranslation>[
              RawTranslation(
                locale: 'de',
                translations: <String, dynamic>{
                  'greeting': 'Hallo',
                  'farewell_de': 'Auf Wiedersehen',
                },
              ),
              RawTranslation(
                locale: 'en',
                translations: <String, dynamic>{
                  'greeting': 'Hello',
                  'farewell': 'Farewell',
                },
              ),
            ],
          ),
        );

        // WHEN
        final List<TranslationEntry> result =
            await translationsService.getAggregatedTranslations('any/path');

        // THEN
        expect(result.length, 3);

        final TranslationEntry greetingEntry =
            result.firstWhere((TranslationEntry e) => e.key == 'greeting');
        expect(greetingEntry.locales, <String>{'en', 'de'});
        final TranslationEntry farewellEntry =
            result.firstWhere((TranslationEntry e) => e.key == 'farewell');
        expect(farewellEntry.locales, <String>{'en'});

        final TranslationEntry farewellDeEntry =
            result.firstWhere((TranslationEntry e) => e.key == 'farewell_de');
        expect(farewellDeEntry.locales, <String>{'de'});
      });
    });
    group('findMissingKeys', () {
      test(
        '''
        GIVEN a list of aggregated translation entries where some keys are missing in certain locales
        WHEN findMissingKeys is called
        THEN it should return a map identifying exactly which keys are missing for each locale        
        ''',
        () {
          // GIVEN
          final List<TranslationEntry> testEntries = <TranslationEntry>[
            TranslationEntry(key: 'key1', locales: <String>{'en', 'de', 'fr'}),
            TranslationEntry(key: 'key2', locales: <String>{'en'}),
            TranslationEntry(key: 'key3', locales: <String>{'de'}),
          ];

          // WHEN
          final Map<String, List<String>> missingKeys =
              translationsService.findMissingKeys(testEntries);

          // THEN
          expect(missingKeys.keys, containsAll(<String>['de', 'en', 'fr']));
          expect(missingKeys['de'], <String>['key2']);
          expect(missingKeys['en'], <String>['key3']);
          expect(missingKeys['fr'], containsAll(<String>['key2', 'key3']));
          expect(missingKeys['fr']!.length, 2);
        },
      );
    });
  });
}

import 'package:intl_usage/src/features/usages/data/services/translation_key_matcher.dart';
import 'package:intl_usage/src/features/usages/domain/services/translation_key_matcher_interface.dart';
import 'package:test/test.dart';

void main() {
  late TranslationKeyMatcher translationKeyMatcher;

  setUp(() {
    translationKeyMatcher = TranslationKeyMatcher();
  });

  group('TranslationKeyMatcher', () {
    group('determineMatchType', () {
      test(
        '''
      GIVEN a full match
      WHEN determineMatchType is called
      THEN it should return MatchType.full
      ''',
        () {
          // GIVEN
          final String translationKey = 'greeting.title';
          final String usageValue = 'greeting.title';

          // WHEN
          final MatchType matchType = translationKeyMatcher.determineMatchType(
            translationKey: translationKey,
            usageValue: usageValue,
          );

          // THEN
          expect(matchType, MatchType.full);
        },
      );
      test(
        '''
        GIVEN translationKey is shorter than usageValue
        WHEN determineMatchType is called
        THEN it should return MatchType.none
      ''',
        () {
          // GIVEN
          final String translationKey = 'greeting';
          final String usageValue = 'greeting.title';

          // WHEN
          final MatchType matchType = translationKeyMatcher.determineMatchType(
            translationKey: translationKey,
            usageValue: usageValue,
          );

          // THEN
          expect(matchType, MatchType.none);
        },
      );
      test(
        '''
      GIVEN a partial match
      WHEN determineMatchType is called
      THEN it should return MatchType.partial
      ''',
        () {
          // GIVEN
          final String translationKey = 'greeting.title';
          final String usageValue = 'greeting';

          // WHEN
          final MatchType matchType = translationKeyMatcher.determineMatchType(
            translationKey: translationKey,
            usageValue: usageValue,
          );

          // THEN
          expect(matchType, MatchType.partial);
        },
      );
      test(
        '''
      GIVEN a partial match with enum part of the key
      WHEN determineMatchType is called
      THEN it should return MatchType.partial
      ''',
        () {
          // GIVEN
          final String translationKey = 'greeting.he.title';
          final String usageValue = r'greeting.$enumValue.title';

          // WHEN
          final MatchType matchType = translationKeyMatcher.determineMatchType(
            translationKey: translationKey,
            usageValue: usageValue,
          );

          // THEN
          expect(matchType, MatchType.partial);
        },
      );
      test(
        '''
      GIVEN a partial match with complex object as part of the key
      WHEN determineMatchType is called
      THEN it should return MatchType.partial
      ''',
        () {
          // GIVEN
          final String translationKey = 'greeting.he.title';
          final String usageValue =
              r'greeting.${complexObject.name.toString()}.title';

          // WHEN
          final MatchType matchType = translationKeyMatcher.determineMatchType(
            translationKey: translationKey,
            usageValue: usageValue,
          );

          // THEN
          expect(matchType, MatchType.partial);
        },
      );
      test(
        '''
      GIVEN a no match
      WHEN determineMatchType is called
      THEN it should return MatchType.none
      ''',
        () {
          // GIVEN
          final String translationKey = 'greeting.title';
          final String usageValue = 'general.ok';

          // WHEN
          final MatchType matchType = translationKeyMatcher.determineMatchType(
            translationKey: translationKey,
            usageValue: usageValue,
          );

          // THEN
          expect(matchType, MatchType.none);
        },
      );
    });
  });
}

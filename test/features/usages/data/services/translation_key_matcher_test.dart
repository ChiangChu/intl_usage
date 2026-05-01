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
      test(
        '''
        GIVEN multiple dynamic segments in usage value
        WHEN determineMatchType is called
        THEN it should return MatchType.partial
        ''',
        () {
          // GIVEN
          final String translationKey = 'a.b.c';
          final String usageValue = r'$x.$y.c';

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
        GIVEN a dynamic first segment in usage value
        WHEN determineMatchType is called
        THEN it should return MatchType.partial
        ''',
        () {
          // GIVEN
          final String translationKey = 'greeting.title';
          final String usageValue = r'$type.title';

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
        GIVEN a dynamic last segment in usage value
        WHEN determineMatchType is called
        THEN it should return MatchType.partial
        ''',
        () {
          // GIVEN
          final String translationKey = 'greeting.title';
          final String usageValue = r'greeting.$type';

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
        GIVEN a dynamic segment but a non-matching static part in usage value
        WHEN determineMatchType is called
        THEN it should return MatchType.none
        ''',
        () {
          // GIVEN
          final String translationKey = 'greeting.title';
          final String usageValue = r'wrong.$type';

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
        GIVEN a usage value with a dynamic segment that makes it longer than the translation key
        WHEN determineMatchType is called
        THEN it should return MatchType.none
        ''',
        () {
          // GIVEN
          final String translationKey = 'greeting';
          final String usageValue = r'$type.extra';

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
        GIVEN a flat key with no dots and an identical usage value
        WHEN determineMatchType is called
        THEN it should return MatchType.full
        ''',
        () {
          // GIVEN
          final String translationKey = 'title';
          final String usageValue = 'title';

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
        GIVEN a usage value with a camelCase enum literal (\${ClassName.value.name})
        WHEN determineMatchType is called
        THEN it should return MatchType.full
        ''',
        () {
          // GIVEN
          final String translationKey = 'greeting.male.title';
          final String usageValue = r'greeting.${MyGender.male.name}.title';

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
        GIVEN a usage value with a snake_case enum literal (\${ClassName.enum_value.name})
        WHEN determineMatchType is called
        THEN it should return MatchType.full
        ''',
        () {
          // GIVEN
          final String translationKey = 'greeting.male_person.title';
          final String usageValue =
              r'greeting.${MyGender.male_person.name}.title';

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
        GIVEN a usage value with an enum literal at the first segment
        WHEN determineMatchType is called
        THEN it should return MatchType.full
        ''',
        () {
          // GIVEN
          final String translationKey = 'some_value.title';
          final String usageValue = r'${MyType.some_value.name}.title';

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
        GIVEN a usage value with a runtime enum variable (no class prefix)
        WHEN determineMatchType is called
        THEN it should return MatchType.partial
        ''',
        () {
          // GIVEN
          final String translationKey = 'greeting.male.title';
          final String usageValue = r'greeting.${gender.name}.title';

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
        GIVEN a usage value with a resolved enum literal that does not match the translation key
        WHEN determineMatchType is called
        THEN it should return MatchType.none
        ''',
        () {
          // GIVEN
          final String translationKey = 'greeting.male.title';
          final String usageValue = r'greeting.${MyGender.female.name}.title';

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

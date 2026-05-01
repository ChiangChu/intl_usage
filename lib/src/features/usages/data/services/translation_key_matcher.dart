import '../../domain/services/translation_key_matcher_interface.dart';

/// A utility class to determine the match type between a translation key and a usage value.
class TranslationKeyMatcher implements ITranslationKeyMatcher {
  // Matches ${ClassName.enumValue.name} where ClassName starts with an uppercase letter.
  // Supports both camelCase and snake_case enum values (e.g., male, male_person).
  static final RegExp _enumLiteralPattern = RegExp(
    r'\$\{[A-Z][A-Za-z0-9]*\.([a-z][A-Za-z0-9_]*)\.name\}',
  );

  static final RegExp _complexExpressionPattern = RegExp(r'\$\{.*?\}');

  @override
  MatchType determineMatchType({
    required String translationKey,
    required String usageValue,
  }) {
    return matchPreprocessed(
      translationKey: translationKey,
      processedValue: preprocessUsageValue(usageValue),
    );
  }

  @override
  MatchType matchPreprocessed({
    required String translationKey,
    required String processedValue,
  }) {
    if (_isFullMatch(translationKey, processedValue)) {
      return MatchType.full;
    }
    if (_isPartialMatch(translationKey, processedValue)) {
      return MatchType.partial;
    }
    return MatchType.none;
  }

  /// Resolves statically-known enum literal patterns and replaces all remaining
  /// dynamic expressions with a wildcard.
  ///
  /// - `${ClassName.enumValue.name}` → `enumValue` (resolvable: class prefix + `.name`)
  /// - `${anything_else}` → `$WILDCARD` (not resolvable at static analysis time)
  @override
  String preprocessUsageValue(String usageValue) {
    String result =
        usageValue.replaceAllMapped(_enumLiteralPattern, (Match match) {
      return match.group(1)!;
    });

    result = result.replaceAll(_complexExpressionPattern, r'$WILDCARD');

    return result;
  }

  /// Checks for a full match between the translation key and the preprocessed usage value.
  bool _isFullMatch(String translationKey, String usageValue) {
    return translationKey == usageValue;
  }

  /// Checks for a partial match. This can be a simple prefix match (e.g., 'a' for 'a.b')
  /// or a match with dynamic/wildcard segments (e.g., 'a.$b.c' for 'a.x.c').
  /// Expects a preprocessed usage value (output of [_preprocessUsageValue]).
  bool _isPartialMatch(String translationKey, String usageValue) {
    final List<String> keyParts = translationKey.split('.');
    final List<String> valueParts = usageValue.split('.');

    // For any kind of partial match, the usage key cannot have more parts than the translation key.
    if (valueParts.length > keyParts.length) {
      return false;
    }

    // If the lengths are equal, it can only be a partial match if it contains a wildcard.
    if (valueParts.length == keyParts.length && !usageValue.contains(r'$')) {
      return false;
    }

    // Check if `valueParts` is a "wildcard prefix" of `keyParts`.
    for (int i = 0; i < valueParts.length; i++) {
      final String valuePart = valueParts[i];
      final String keyPart = keyParts[i];

      final bool isDynamic = valuePart.startsWith(r'$');
      if (!isDynamic && valuePart != keyPart) {
        return false;
      }
    }

    return true;
  }
}

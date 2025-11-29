import '../../domain/services/translation_key_matcher_interface.dart';

/// A utility class to determine the match type between a translation key and a usage value.
class TranslationKeyMatcher implements ITranslationKeyMatcher {
  @override
  MatchType determineMatchType({
    required String translationKey,
    required String usageValue,
  }) {
    if (_isFullMatch(translationKey, usageValue)) {
      return MatchType.full;
    }
    if (_isPartialMatch(translationKey, usageValue)) {
      return MatchType.partial;
    }
    return MatchType.none;
  }

  /// Checks for a full match between the translation key and the usage value.
  bool _isFullMatch(String translationKey, String usageValue) {
    return translationKey == usageValue;
  }

  /// Checks for a partial match. This can be a simple prefix match (e.g., 'a' for 'a.b')
  /// or a match with dynamic/wildcard segments (e.g., 'a.$b.c' for 'a.x.c').
  bool _isPartialMatch(String translationKey, String usageValue) {
    // First, handle complex dynamic parts like ${...} by replacing them with a simple wildcard.
    // The non-greedy `.*?` ensures we only match until the first `}`.
    final String processedUsageValue =
        usageValue.replaceAll(RegExp(r'\$\{.*?\}'), r'$WILDCARD');

    final List<String> keyParts = translationKey.split('.');
    final List<String> valueParts = processedUsageValue.split('.');

    // For any kind of partial match, the usage key cannot have more parts than the translation key.
    if (valueParts.length > keyParts.length) {
      return false;
    }

    // If the lengths are equal, it can only be a partial match if it's not also a full match
    // (which is already checked) and contains a wildcard.
    if (valueParts.length == keyParts.length &&
        !processedUsageValue.contains(r'$')) {
      // This is not a prefix match and contains no wildcards, so it would have to be a full match,
      // which is already handled. So it's not a partial match.
      return false;
    }

    // Now, check if `valueParts` is a "wildcard prefix" of `keyParts`.
    for (int i = 0; i < valueParts.length; i++) {
      final String valuePart = valueParts[i];
      final String keyPart = keyParts[i];

      final bool isDynamic = valuePart.startsWith(r'$');
      if (!isDynamic && valuePart != keyPart) {
        // If a part is not dynamic and doesn't match, it's not a partial match.
        return false;
      }
    }

    // If the loop completes, it means the usage value is a valid prefix (with potential wildcards)
    // of the translation key.
    return true;
  }
}

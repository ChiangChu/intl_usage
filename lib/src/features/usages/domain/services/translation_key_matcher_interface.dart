/// An enum representing the type of match found for a translation key.
enum MatchType {
  /// A full match, where the usage value is identical to the translation key.
  full,

  /// A partial match, where the usage value is a prefix of the translation key.
  partial,

  /// No match found.
  none
}

/// Abstract interface for a utility that determines the match type
/// between a translation key and a usage value.
abstract interface class ITranslationKeyMatcher {
  /// Determines the match type between a translation key and a usage value.
  MatchType determineMatchType({
    required String translationKey,
    required String usageValue,
  });
}

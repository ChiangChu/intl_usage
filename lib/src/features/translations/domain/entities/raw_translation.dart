/// Represents the raw, unprocessed translation data for a single locale.
class RawTranslation {
  /// The locale of the translations (e.g., 'en', 'de-DE').
  final String locale;

  /// A map of translation keys to their corresponding values.
  final Map<String, dynamic> translations;

  /// Creates a new instance of [RawTranslation].
  RawTranslation({required this.locale, required this.translations});
}

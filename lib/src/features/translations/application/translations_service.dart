import '../domain/entities/raw_translation.dart';
import '../domain/entities/translation_entry.dart';
import '../domain/repositories/translations_repository_interface.dart';

/// A service that handles the business logic related to translations.
///
/// This service orchestrates fetching, processing, and analyzing
/// translation data.
class TranslationsService {
  final ITranslationsRepository _translationsRepo;

  TranslationsService(this._translationsRepo);

  /// Fetches raw translation data from the given [path], aggregates it by key,
  /// and returns a consolidated list of [TranslationEntry] objects.
  Future<List<TranslationEntry>> getAggregatedTranslations(String path) async {
    final List<RawTranslation> rawTranslations =
        await _translationsRepo.getTranslationsFromPath(path);

    final Map<String, TranslationEntry> entriesMap =
        <String, TranslationEntry>{};

    for (final RawTranslation raw in rawTranslations) {
      for (final String key in raw.translations.keys) {
        final TranslationEntry? existing = entriesMap[key];
        if (existing != null) {
          entriesMap[key] = existing
              .copyWith(locales: <String>{...existing.locales, raw.locale});
        } else {
          entriesMap[key] =
              TranslationEntry(key: key, locales: <String>{raw.locale});
        }
      }
    }
    return entriesMap.values.toList();
  }

  /// Analyzes a list of [translations] to find all unique locales and
  /// identifies which translation keys are missing for each locale.
  ///
  /// Returns a map where the key is the locale and the value is a list of
  /// missing translation keys.
  Map<String, List<String>> findMissingKeys(
    List<TranslationEntry> translations,
  ) {
    Map<String, List<String>> missingKeys = <String, List<String>>{};
    TranslationEntry translationEntryWithAllLocales = translations.reduce(
      (TranslationEntry a, TranslationEntry b) =>
          b.locales.length > a.locales.length ? b : a,
    );

    for (TranslationEntry entry in translations) {
      Set<String> missingLocales =
          translationEntryWithAllLocales.locales.difference(entry.locales);
      for (String missingLocale in missingLocales) {
        missingKeys.putIfAbsent(missingLocale, () => <String>[]).add(entry.key);
      }
    }

    return missingKeys;
  }
}

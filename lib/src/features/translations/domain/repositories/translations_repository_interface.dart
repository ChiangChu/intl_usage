import '../entities/raw_translation.dart';

/// An interface for a repository that handles fetching translation data.
///
/// This contract decouples the application from the concrete implementation of
/// how translation files are read and processed.
abstract interface class ITranslationsRepository {
  /// Fetches and parses all translation files from the given [path].
  ///
  /// Returns a list of [RawTranslation] objects, each representing the
  /// unprocessed data from a single translation file.
  Future<List<RawTranslation>> getTranslationsFromPath(String path);
}

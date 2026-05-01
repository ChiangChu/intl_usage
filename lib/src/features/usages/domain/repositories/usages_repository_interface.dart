import '../entities/usage_entry.dart';

/// Repository interface for finding translation key usages in source files.
abstract interface class IUsagesRepository {
  /// Finds all usages of the given [translationKeys] in the project source files.
  Future<Map<String, Set<UsageEntry>>> findUsages(List<String> translationKeys);
}

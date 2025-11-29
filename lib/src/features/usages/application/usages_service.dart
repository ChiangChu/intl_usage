import '../../translations/domain/entities/translation_entry.dart';
import '../domain/entities/usage_entry.dart';
import '../domain/repositories/usages_repository_interface.dart';

/// A service responsible for the business logic of finding translation usages.
class UsagesService {
  final IUsagesRepository _usagesRepository;

  /// Creates a new instance of [UsagesService].
  UsagesService(this._usagesRepository);

  /// Finds all project usages for a given list of [TranslationEntry] objects.
  ///
  /// It extracts the keys from the entries and delegates the search to the
  /// underlying repository.
  Future<Map<String, Set<UsageEntry>>> findUsagesFor(
    List<TranslationEntry> entries,
  ) async {
    final List<String> keys =
        entries.map((TranslationEntry e) => e.key).toList();

    return _usagesRepository.findUsages(keys);
  }
}

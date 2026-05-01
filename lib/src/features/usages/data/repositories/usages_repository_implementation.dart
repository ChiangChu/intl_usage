import '../../../../core/domain/entities/project_file.dart';
import '../../../../core/domain/repositories/file_system_repository_interface.dart';
import '../../domain/entities/usage_entry.dart';
import '../../domain/services/translation_key_matcher_interface.dart';
import '../../domain/repositories/usages_repository_interface.dart';

/// A repository that handles finding usages of translation keys in the project.
class UsagesRepositoryImpl implements IUsagesRepository {
  final IFileSystemRepository _fileSystemRepo;
  final ITranslationKeyMatcher _matcher;

  /// Creates a new instance of [UsagesRepositoryImpl].
  UsagesRepositoryImpl(this._fileSystemRepo, this._matcher);

  // Matches string literals (single or double quoted) containing valid key characters.
  // Includes $, {, } to support Dart string interpolation like '$var' and '${expr}'.
  static final RegExp _stringLiteralPattern =
      RegExp("((?:'|\")[A-Za-z0-9._\${}-]+(?:'|\"))");

  static final RegExp _quotePattern = RegExp('["\']');

  @override
  Future<Map<String, Set<UsageEntry>>> findUsages(
    List<String> translationKeys,
  ) async {
    final List<ProjectFile> dartFiles =
        await _fileSystemRepo.findFilesByExtension('.dart');
    final Map<String, Set<UsageEntry>> usageMap = <String, Set<UsageEntry>>{
      for (final String key in translationKeys) key: <UsageEntry>{},
    };

    for (final ProjectFile file in dartFiles) {
      final List<String> lines = file.content.split('\n');
      for (int i = 0; i < lines.length; i++) {
        final String line = lines[i];
        final List<RegExpMatch> matches =
            _stringLiteralPattern.allMatches(line).toList();
        if (matches.isEmpty) continue;

        // Preprocess each match value once, independent of the translation keys.
        final List<String> processedValues = matches
            .map((RegExpMatch m) => m[0]!.replaceAll(_quotePattern, ''))
            .map(_matcher.preprocessUsageValue)
            .toList();

        for (final String key in translationKeys) {
          for (final String processedValue in processedValues) {
            final MatchType matchType = _matcher.matchPreprocessed(
              translationKey: key,
              processedValue: processedValue,
            );
            if (matchType != MatchType.none) {
              usageMap[key]!.add(
                UsageEntry(
                  filename: file.path,
                  line: i + 1,
                  isUnsure: matchType != MatchType.full,
                ),
              );
              break;
            }
          }
        }
      }
    }

    return usageMap;
  }
}

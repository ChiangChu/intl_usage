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

  @override
  Future<Map<String, Set<UsageEntry>>> findUsages(
    List<String> translationKeys,
  ) async {
    final List<ProjectFile> dartFiles =
        await _fileSystemRepo.findFilesByExtension('.dart');
    final Map<String, Set<UsageEntry>> usageMap = <String, Set<UsageEntry>>{
      for (final String key in translationKeys) key: <UsageEntry>{},
    };

    // Precompile the regular expression for matching translation keys.
    final RegExp regExp = RegExp("((?:'|\")[A-Za-z0-9._-]+(?:'|\"))");

    for (final ProjectFile file in dartFiles) {
      final List<String> lines = file.content.split('\n');
      for (int i = 0; i < lines.length; i++) {
        final String line = lines[i];
        final List<RegExpMatch> matches = regExp.allMatches(line).toList();
        for (final String key in translationKeys) {
          for (final RegExpMatch match in matches) {
            final MatchType matchType = _matcher.determineMatchType(
              translationKey: key,
              usageValue: match[0]!.replaceAll(RegExp('["\']'), ''),
            );
            if (matchType != MatchType.none) {
              // Add a UsageEntry for the matched key.
              usageMap[key]!.add(
                UsageEntry(
                  filename: file.path,
                  line: i + 1,
                  isUnsure: matchType != MatchType.full,
                ),
              );
              // Move to the next line if a match is found.
              break;
            }
          }
        }
      }
    }

    return usageMap;
  }
}

import 'dart:io';

import 'package:intl_usage/src/file_system/application/file_system_utils.dart';

import '../../../intl_usage.dart';

/// A utility class for analyzing the usage of translation entries within a Dart project.
class UsagesUtils {
  final Logger _logger = Logger();

  /// Analyzes the usage of the provided [entries] within the 'lib' directory of the project.
  ///
  /// Returns a map where keys are translation keys and values are sets of [UsageEntry] objects
  /// representing the locations where those keys are used.
  ///
  /// If [debug] is true, additional logging information is printed to the console.
  Future<Map<String, Set<UsageEntry>>> getUsages(
    List<TranslationEntry> entries, {
    bool debug = false,
    required FileSystemUtils fileSystemUtils,
  }) async {
    // Initialize a map to store usage information.
    Map<String, Set<UsageEntry>> usages = <String, Set<UsageEntry>>{};

    // Search for Dart files within the 'lib' directory.
    List<File> dartFiles = await fileSystemUtils.searchForFiles(
      relativePath: 'lib',
      extension: FileExtension.dart,
    );

    // Initialize the usages map with empty sets for each translation key.
    usages.addEntries(
        entries.map((entry) => MapEntry(entry.key, <UsageEntry>{})));

    // Precompile the regular expression for matching translation keys.
    RegExp regExp = RegExp("((?:'|\")[A-Za-z0-9.}{\$]+(?:'|\"))");

    // Iterate through each Dart file.
    for (File currentFile in dartFiles) {
      // Calculate the relative path of the file once.
      String relativePath =
          currentFile.path.substring(currentFile.path.indexOf('lib'));
      List<String> lines = await currentFile.readAsLines();
      if (debug) {
        _logger.printError("working on file: ${currentFile.path}");
      }
      // Iterate through each translation entry.
      for (TranslationEntry entry in entries) {
        double coverage = 0.0;
        // Store the translation key for faster access.
        String key = entry.key;

        // Iterate through each line in the file.
        for (int i = 0; i < lines.length; i++) {
          String line = lines[i];
          // Find all matches of the translation key pattern in the line.
          List<RegExpMatch> matches = regExp.allMatches(line).toList();

          // Check each match for coverage.
          for (RegExpMatch match in matches) {
            MatchType matchType = _determineMatchType(
              translationKey: key,
              usageValue: match[0]!.replaceAll(RegExp('["\']'), ''),
            );
            if (matchType != MatchType.none) {
              // Add a UsageEntry for the matched key.
              usages[entry.key]!.add(UsageEntry(
                filename: relativePath,
                line: i + 1,
                isUnsure: matchType != MatchType.full,
              ));
              // Move to the next line if a match is found.
              break;
            }
          }
        }

        if (debug) {
          _logger.print('${entry.key} with coverage of $coverage found');
        }
      }
    }

    // Return the map of translation key usages.
    return usages;
  }

  /// Determines the match type between a translation key and a usage value.
  ///
  /// [translationKey] The translation key to compare./// [usageValue] The value found in the code usage.
  ///
  /// Returns a [MatchType] indicating whether the key and value match fully,
  /// partially, or not at all.
  MatchType _determineMatchType({
    required String translationKey,
    required String usageValue,
  }) {
    if (usageValue == translationKey) {
      return MatchType.full; // Full match
    }

    List<String> keyParts = translationKey.split('.');
    List<String> valueParts = usageValue.split('.');

    if (valueParts.length < keyParts.length) {
      bool isPartial = keyParts
          .sublist(0, valueParts.length)
          .every((part) => valueParts.contains(part));
      if (isPartial) {
        return MatchType.partial; // Partial match
      }
    }

    return MatchType.none;
  }
}

enum MatchType { full, partial, none }

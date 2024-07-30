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
  }) async {
    // Initialize a map to store usage information.
    Map<String, Set<UsageEntry>> usages = <String, Set<UsageEntry>>{};

    // Search for Dart files within the 'lib' directory.
    List<FileSystemEntity> dartFiles = await FileSystemUtils.searchForFiles(
      relativePath: 'lib',
      extension: FileExtension.dart,
    );

    // Initialize the usages map with empty sets for each translation key.
    usages.addEntries(
        entries.map((entry) => MapEntry(entry.key, <UsageEntry>{})));

    // Precompile the regular expression for matching translation keys.
    RegExp regExp = RegExp("((?:'|\")[A-Za-z0-9}{\$]+(?:'|\"))");

    // Iterate through each Dart file.
    for (FileSystemEntity file in dartFiles) {
      File currentFile = File(file.path);
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
          coverage = 0.0;

          // Check each match for coverage.
          for (RegExpMatch match in matches) {
            coverage = _calculateCoverage(
              translationKey: key,
              usageValue: match[0]!,
            );
            if (coverage >= 0) {
              // Add a UsageEntry for the matched key.
              usages[entry.key]!.add(UsageEntry(
                filename: relativePath,
                line: i + 1,
                isUnsure: coverage != 1.0,
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

  /// Calculates the coverage of a translation [translationKey] within a given [usageValue].
  ///
  /// Returns a double representing the coverage, where 1.0 indicates a full match
  /// and 0.0 indicates no match.
  double _calculateCoverage({
    required String translationKey,
    required String usageValue,
  }) {
    if (usageValue == translationKey) {
      // Full match, no need for splitting.
      return 1.0;
    }

    double coverage = 0.0;

    // Split the key and value to check for partial matches.
    List<String> keyParts = translationKey.split('.');
    List<String> valueParts = usageValue.split('.');

    for (int i = 0; i < keyParts.length; i++) {
      String keyPart = keyParts[i];
      if (valueParts.length > i) {
        // Remove quotes from the value part.
        String valuePart =
            valueParts[i].replaceAll('\'', '').replaceAll("\"", '');

        if (keyPart == valuePart) {
          // Increment coverage based on the number of matching parts.
          coverage += 1.0 / keyParts.length;
        }
      } else {
        // No match for this part, reset coverage and break.
        coverage = 0.0;
        break;
      }
    }

    return coverage;
  }
}

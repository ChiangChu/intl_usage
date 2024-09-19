import 'dart:io';

import 'package:args/args.dart';
import 'package:intl_usage/intl_usage.dart';
import 'package:intl_usage/src/arg_parser_util.dart';
import 'package:intl_usage/src/file_system/application/file_system_utils.dart';

/// Type definition for the usage result, containing the number of unused and unsure entries.
typedef UsageResult = ({int unused, int unsure});

final Logger _logger = Logger();

/// Entry point for the command-line application.
Future<void> main(List<String> args) async {
  final ArgParser parser = ArgParserUtil().parser;
  final FileSystemUtils utils = FileSystemUtils();
  final UsagesUtils usagesUtils = UsagesUtils();
  final TranslationsUtil translationsUtil = TranslationsUtil();

  // Parse the command-line arguments.
  ArgResults results = parser.parse(args);

  // Handle the help flag.
  if (results.flag(ArgParserUtil.help)) {
    _logger.print(parser.usage);
    exit(0);
  }

  UsageResult usageResult;

  Configuration config = await ConfigurationUtils.loadConfiguration();
  String path = config.path ?? results.option(ArgParserUtil.path) as String;

  try {
    // Get the translation entries from the specified path.
    List<TranslationEntry> translations =
        await translationsUtil.getTranslations(path, fileSystemUtils: utils);

    // Get the usage results (unused and unsure entries).
    usageResult = await _printUsages(
      usagesUtils.getUsages(
        translations,
        fileSystemUtils: utils,
      ),
    );
  } on FileNotFoundException catch (e) {
    // Handle the case where no translations are found.
    _logger.printError(e.message);
    exit(0);
  }

  // Print summary and exit based on the usage results.
  if (usageResult.unsure > 0) {
    _logger.printError('Found ${usageResult.unused} unused translations!');
    exit(1);
  } else if (usageResult.unsure > 0) {
    _logger.printWarning('Found ${usageResult.unsure} of unsure entries');
  } else {
    _logger.printSuccess('No unused keys found!');
  }

  exit(0);
}

/// Prints usage information and returns the number of unused and unsure entries.
///
/// [usagesFuture] A future resolving to a map of translation keys to their usage entries.
///
/// Returns a [UsageResult] object containing the number of unused and unsure entries.
Future<UsageResult> _printUsages(
  Future<Map<String, Set<UsageEntry>>> usagesFuture,
) async {
  final Map<String, Set<UsageEntry>> usages = await usagesFuture;
  int numberOfUnusedEntries = 0;
  int numberOfUnsureEntries = 0;

  // Iterate through each translation key and its usages.
  for (MapEntry<String, Set<UsageEntry>> entry in usages.entries) {
    if (entry.value.isEmpty) {
      // Log an error for unused keys and increment the count.
      _logger.printError('${entry.key} [no usages found]');
      numberOfUnusedEntries++;
    } else if (entry.value.every((usage) => usage.isUnsure)) {
      // Log a warning for keys with only unsure usages and increment the count.
      _logger.printWarning('${entry.key} [unsure]');
      numberOfUnsureEntries++;
    }
  }

  // Return the number of unused and unsure entries as a UsageResult object.
  return (unsure: numberOfUnsureEntries, unused: numberOfUnusedEntries);
}

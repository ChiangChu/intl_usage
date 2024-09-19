import 'dart:io';

import 'package:args/args.dart';
import 'package:intl_usage/intl_usage.dart';
import 'package:intl_usage/src/arg_parser_util.dart';
import 'package:intl_usage/src/file_system/application/file_system_utils.dart';

final Logger _logger = Logger();

/// Entry point for the command-line application.
Future<void> main(List<String> args) async {
  final FileSystemUtils utils = FileSystemUtils();
  final ArgParser parser = ArgParserUtil().parser;
  final TranslationsUtil translationsUtil = TranslationsUtil();

  // Parse the command-line arguments.
  ArgResults results = parser.parse(args);

  // Handle the help flag.
  if (results.flag(ArgParserUtil.help)) {
    _logger.print(parser.usage);
    exit(0);
  }

  // Load configuration and get the path to translation files.
  Configuration config = await ConfigurationUtils.loadConfiguration();
  String path = config.path ?? results.option(ArgParserUtil.path) as String;

  List<TranslationEntry> translations;
  try {
    // Get the translation entries from the specified path.
    translations =
        await translationsUtil.getTranslations(path, fileSystemUtils: utils);
  } on FileNotFoundException catch (e) {
    // Handle the case where no translations are found.
    _logger.printError(e.message);
    exit(0);
  }

  // Identify missing translation keys.
  Map<String, List<String>> missingKeys =
      translationsUtil.findMissingKeys(translations);

  // Report any missing keys.
  if (missingKeys.isNotEmpty) {
    for (var entry in missingKeys.entries) {
      _logger.printError(
          'Locale ${entry.key} is missing keys: ${entry.value.join(", ")}');
    }
    exit(1); // Indicate an error (missing keys found).
  }

  exit(0); // Indicate success (no missing keys).
}

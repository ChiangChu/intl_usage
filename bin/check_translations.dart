import 'dart:io';

import 'package:args/args.dart';
import 'package:intl_usage/src/arg_parser_util.dart';
import 'package:intl_usage/src/core/application/configuration_service.dart';
import 'package:intl_usage/src/core/di/dependency_container.dart';
import 'package:intl_usage/src/features/translations/application/translations_service.dart';
import 'package:intl_usage/src/features/translations/domain/entities/translation_entry.dart';
import 'package:intl_usage/src/logger.dart';

final Logger _logger = Logger();

/// Entry point for the command-line application.
Future<void> main(List<String> args) async {
  final ArgParser parser = ArgParserUtil().parser;
  final DependencyContainer container = DependencyContainer();

  final ConfigurationService configService = container.configurationService;
  final TranslationsService translationsService = container.translationsService;

  // Parse the command-line arguments.
  ArgResults results = parser.parse(args);

  // Handle the help flag.
  if (results.flag(ArgParserUtil.help)) {
    _logger.print(parser.usage);
    exit(0);
  }

  final String path = await configService.getTranslationPath(results);
  final List<TranslationEntry> translations =
      await translationsService.getAggregatedTranslations(path);
  final Map<String, List<String>> missingKeys =
      translationsService.findMissingKeys(translations);

  // Report any missing keys.
  if (missingKeys.isNotEmpty) {
    for (MapEntry<String, List<String>> entry in missingKeys.entries) {
      _logger.printError(
        'Locale ${entry.key} is missing keys: ${entry.value.join(", ")}',
      );
    }
    exit(1); // Indicate an error (missing keys found).
  }

  exit(0); // Indicate success (no missing keys).
}

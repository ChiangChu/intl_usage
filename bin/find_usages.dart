import 'dart:io';

import 'package:args/args.dart';
import 'package:intl_usage/src/arg_parser_util.dart';
import 'package:intl_usage/src/core/application/configuration_service.dart';
import 'package:intl_usage/src/core/di/dependency_container.dart';
import 'package:intl_usage/src/features/translations/application/translations_service.dart';
import 'package:intl_usage/src/features/translations/domain/entities/translation_entry.dart';
import 'package:intl_usage/src/features/usages/application/usages_service.dart';
import 'package:intl_usage/src/features/usages/domain/entities/usage_entry.dart';
import 'package:intl_usage/src/logger.dart';

/// Type definition for the usage result, containing the number of unused and unsure entries.
typedef UsageResult = ({int unused, int unsure});

final Logger _logger = Logger();

/// Entry point for the command-line application.
Future<void> main(List<String> args) async {
  final DependencyContainer container = DependencyContainer();

  final ConfigurationService configService = container.configurationService;
  final TranslationsService translationService = container.translationsService;
  final UsagesService usagesService = container.usagesService;
  final ArgParser parser = ArgParserUtil().parser;

  // Parse the command-line arguments.
  ArgResults results = parser.parse(args);

  // Handle the help flag.
  if (results.flag(ArgParserUtil.help)) {
    _logger.print(parser.usage);
    exit(0);
  }

  try {
    _logger.print('Resolving configuration...');
    final String path = await configService.getTranslationPath(results);

    _logger.print('loading translations from "$path"...');
    final List<TranslationEntry> translations =
        await translationService.getAggregatedTranslations(path);

    _logger.print('Searching for usages in project...');
    final Map<String, Set<UsageEntry>> usages =
        await usagesService.findUsagesFor(translations);

    final UsageResult usageResult = _processUsages(usages);
    // Print summary and exit based on the usage results.
    if (usageResult.unsure > 0) {
      _logger.printError('Found ${usageResult.unused} unused translations!');
      exit(1);
    } else if (usageResult.unsure > 0) {
      _logger.printWarning('Found ${usageResult.unsure} of unsure entries');
    } else {
      _logger.printSuccess('No unused keys found!');
    }
  } catch (e) {
    _logger.printError('An unexpected error occured: ${e.toString()}');
    exit(1);
  }
}

UsageResult _processUsages(Map<String, Set<UsageEntry>> usages) {
  int numberOfUnusedEntries = 0;
  int numberOfUnsureEntries = 0;

  for (final MapEntry<String, Set<UsageEntry>> entry in usages.entries) {
    if (entry.value.isEmpty) {
      _logger.printError('${entry.key} [no usages found]');
      numberOfUnusedEntries++;
    } else if (entry.value.every((UsageEntry usage) => usage.isUnsure)) {
      _logger.printWarning('${entry.key} [unsure]');
      numberOfUnsureEntries++;
    }
  }

  return (unsure: numberOfUnsureEntries, unused: numberOfUnusedEntries);
}

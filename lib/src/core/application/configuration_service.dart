import 'package:args/args.dart';

import '../domain/entities/configuration.dart';
import '../domain/repositories/configuration_repository_interface.dart';

/// A service responsible for resolving the final application configuration.
///
/// It orchestrates the process of loading configuration from a file and
/// merging it with command-line arguments, where command-line arguments
/// always take precedence.
class ConfigurationService {
  final IConfigurationRepository _configRepo;

  /// Creates a new instance of [ConfigurationService].
  ConfigurationService(this._configRepo);

  /// Determines the definitive path for translations to be processed.
  ///
  /// The resolution strategy is as follows:
  /// 1. If a path is provided via [argResults] (command-line), it is used.
  /// 2. Otherwise, it attempts to load the path from the configuration file.
  /// 3. If no path can be resolved, it throws an [Exception].
  Future<String> getTranslationPath(ArgResults argResults) async {
    final String? cliPath = argResults['path'] as String?;
    if (cliPath != null && cliPath.isNotEmpty) {
      return cliPath;
    }

    final Configuration config = await _configRepo.loadConfiguration();
    if (config.path != null && config.path!.isNotEmpty) {
      return config.path!;
    }

    throw Exception('Path for translations could not be resolved.');
  }
}

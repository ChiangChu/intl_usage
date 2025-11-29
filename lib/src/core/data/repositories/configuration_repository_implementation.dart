import 'package:yaml/yaml.dart';

import '../../domain/entities/configuration.dart';
import '../../domain/entities/project_file.dart';
import '../../domain/repositories/configuration_repository_interface.dart';
import '../../domain/repositories/file_system_repository_interface.dart';

/// A repository that handles loading the configuration for the application.
class ConfigurationRepositoryImpl implements IConfigurationRepository {
  final IFileSystemRepository _fileSystemRepo;

  /// Creates a new instance of [ConfigurationRepositoryImpl].
  ConfigurationRepositoryImpl(this._fileSystemRepo);

  @override
  Future<Configuration> loadConfiguration() async {
    final ProjectFile? configFile =
        await _fileSystemRepo.findFileByName('intl_usage.yaml');
    if (configFile != null) {
      final YamlMap config = loadYaml(configFile.content);

      return Configuration(path: config['path']);
    }
    return Configuration();
  }
}

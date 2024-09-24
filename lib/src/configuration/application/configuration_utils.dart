import 'dart:io';

import 'package:yaml/yaml.dart';

import '../domain/configuration.dart';

/// Utility class for handling configuration loading.
class ConfigurationUtils {
  /// The name of the configuration file.
  static String configFilename = 'intl_usage.yaml';
  static final String _excludedKeysKey = 'known_used_keys';
  static final String _pathKey = 'path';

  /// Loads the configuration from the `intl_usage.yaml` file.
  ///
  /// Returns a [Configuration] object with the loaded settings.
  /// If the configuration file is not found, returns a default
  /// [Configuration] object.
  static Future<Configuration> loadConfiguration() async {
    Directory currentDir = Directory.current;
    File configFile = File('${currentDir.path}/$configFilename');
    if (!await configFile.exists()) {
      return Configuration(); // Return default configuration if file not found.
    }
    try {
      YamlMap config = loadYaml(await configFile.readAsString());
      List<String> excludedKeys = config.containsKey(_excludedKeysKey)
          ? List<String>.from(config[_excludedKeysKey] as List<dynamic>)
          : <String>[];
      return Configuration(
        path: config[_pathKey],
        exclude: excludedKeys,
      );
    } catch (e) {
      return Configuration(); // Return default configuration on error.
    }
  }
}

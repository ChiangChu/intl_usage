import '../entities/configuration.dart';

/// An interface for a repository that handles loading application configuration.
///
/// This contract decouples the application from the concrete implementation of
/// how and where the configuration is stored (e.g., from a `pubspec.yaml`
/// or a dedicated `.json` file).
abstract interface class IConfigurationRepository {
  /// Loads the application [Configuration] from its defined source.
  ///
  /// Throws an exception if the configuration source cannot be found or parsed.
  Future<Configuration> loadConfiguration();
}

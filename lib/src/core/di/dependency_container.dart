import '../../features/translations/application/translations_service.dart';
import '../../features/translations/data/repositories/translations_repository_implementation.dart';
import '../../features/translations/domain/repositories/translations_repository_interface.dart';
import '../../features/usages/application/usages_service.dart';
import '../../features/usages/data/repositories/usages_repository_implementation.dart';
import '../../features/usages/domain/repositories/usages_repository_interface.dart';
import '../application/configuration_service.dart';
import '../data/repositories/configuration_repository_implementation.dart';
import '../data/repositories/file_system_repository.dart';
import '../domain/repositories/configuration_repository_interface.dart';
import '../domain/repositories/file_system_repository_interface.dart';

/// A simple service locator that initializes and wires up all application
/// dependencies at a single, central location (Composition Root).
///
/// This container is responsible for creating instances of repositories and
/// services, ensuring that each part of the application receives the
/// dependencies it needs without having to construct them itself.
class DependencyContainer {
  late final ConfigurationService configurationService;
  late final TranslationsService translationsService;
  late final UsagesService usagesService;

  late final IFileSystemRepository _fileSystemRepository;
  late final IConfigurationRepository _configurationRepository;
  late final ITranslationsRepository _translationsRepository;
  late final IUsagesRepository _usagesRepository;

  /// Creates a new instance of [DependencyContainer].
  DependencyContainer() {
    _fileSystemRepository = FileSystemRepository();

    _configurationRepository =
        ConfigurationRepositoryImpl(_fileSystemRepository);
    _translationsRepository = TranslationsRepositoryImpl(_fileSystemRepository);
    _usagesRepository = UsagesRepositoryImpl(_fileSystemRepository);

    configurationService = ConfigurationService(_configurationRepository);
    translationsService = TranslationsService(_translationsRepository);
    usagesService = UsagesService(_usagesRepository);
  }
}

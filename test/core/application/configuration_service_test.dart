import 'package:args/args.dart';
import 'package:intl_usage/src/core/application/configuration_service.dart';
import 'package:intl_usage/src/core/domain/entities/configuration.dart';
import 'package:intl_usage/src/core/domain/repositories/configuration_repository_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockConfigurationRepository extends Mock
    implements IConfigurationRepository {}

class MockArgResults extends Mock implements ArgResults {}

void main() {
  late ConfigurationService configurationService;
  late IConfigurationRepository mockConfigurationRepository;
  late ArgResults mockArgResults;

  setUp(() {
    mockConfigurationRepository = MockConfigurationRepository();
    mockArgResults = MockArgResults();
    configurationService = ConfigurationService(mockConfigurationRepository);

    registerFallbackValue(Configuration(path: 'default'));
  });

  group('ConfigurationService', () {
    group('getTranslationsPath', () {
      test(
        '''
      GIVEN a path is provided via command-line arguments
      AND a different path is set in the configuration file
      WHEN getTranslationPath is called
      THEN it should return the path from the command-line arguments
      ''',
        () async {
          // GIVEN
          when(() => mockArgResults['path']).thenReturn('path/from/cli');

          // WHEN
          final String path =
              await configurationService.getTranslationPath(mockArgResults);

          // THEN
          expect(path, 'path/from/cli');
          verifyNever(() => mockConfigurationRepository.loadConfiguration());
        },
      );

      test(
        '''
      GIVEN no path is provided via command-line arguments
      AND a path is set in the configuration file
      WHEN getTranslationPath is called
      THEN it should return the path from the configuration file
      ''',
        () async {
          // GIVEN
          when(() => mockArgResults['path']).thenReturn(null);
          when(() => mockConfigurationRepository.loadConfiguration())
              .thenAnswer(
            (_) async => Configuration(path: 'path/from/file'),
          );

          // WHEN
          final String path =
              await configurationService.getTranslationPath(mockArgResults);

          // THEN
          expect(path, 'path/from/file');
          verify(() => mockConfigurationRepository.loadConfiguration())
              .called(1);
        },
      );

      test(
        '''
      GIVEN an EMPTY path is provided via command-line arguments
      AND a path is set in the configuration file
      WHEN getTranslationPath is called
      THEN it should fall back and return the path from the configuration file
      ''',
        () async {
          // GIVEN
          when(() => mockArgResults['path']).thenReturn('');
          when(() => mockConfigurationRepository.loadConfiguration())
              .thenAnswer(
            (_) async => Configuration(path: 'path/from/file'),
          );

          // WHEN
          final String path =
              await configurationService.getTranslationPath(mockArgResults);

          // THEN
          expect(path, 'path/from/file');
        },
      );

      test(
        '''
      GIVEN no path is provided anywhere (neither CLI nor file)
      WHEN getTranslationPath is called
      THEN it should throw an Exception
      ''',
        () async {
          // GIVEN
          when(() => mockArgResults['path']).thenReturn(null);
          when(() => mockConfigurationRepository.loadConfiguration())
              .thenAnswer(
            (_) async => Configuration(path: null),
          );

          // WHEN & THEN
          expect(
            () => configurationService.getTranslationPath(mockArgResults),
            throwsA(isA<Exception>()),
          );
        },
      );
    });
  });
}

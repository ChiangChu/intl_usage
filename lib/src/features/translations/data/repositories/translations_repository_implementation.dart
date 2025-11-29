import 'dart:convert';

import 'package:flat/flat.dart';
import '../../../../core/domain/entities/project_file.dart';
import '../../../../core/domain/repositories/file_system_repository_interface.dart';
import '../../domain/repositories/translations_repository_interface.dart';
import 'package:path/path.dart';

import '../../domain/entities/raw_translation.dart';

/// A repository that handles fetching and parsing translation files.
class TranslationsRepositoryImpl implements ITranslationsRepository {
  final IFileSystemRepository _fileSystemRepo;

  /// Creates a new instance of [TranslationsRepositoryImpl].
  TranslationsRepositoryImpl(this._fileSystemRepo);

  @override
  Future<List<RawTranslation>> getTranslationsFromPath(String path) async {
    final List<ProjectFile> allProjectFiles =
        await _fileSystemRepo.findFilesByExtension('.json');
    final List<ProjectFile> translationFiles = allProjectFiles
        .where((ProjectFile file) => file.path.startsWith(path))
        .toList();

    final List<RawTranslation> rawTranslations = <RawTranslation>[];
    final RegExp regExp = RegExp(r'^[a-zA-Z]{2}(-[a-zA-Z]{2})?\.json$');
    for (final ProjectFile file in translationFiles) {
      final String? localeMatch = regExp.stringMatch(basename(file.path));
      if (localeMatch == null) continue;

      final String locale = localeMatch.replaceAll('.json', '');
      final Map<String, dynamic> json = jsonDecode(file.content);
      final Map<String, dynamic> flatTranslations = flatten(json);

      rawTranslations
          .add(RawTranslation(locale: locale, translations: flatTranslations));
    }

    return rawTranslations;
  }
}

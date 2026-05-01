import 'dart:io';

import 'package:path/path.dart' as p;

import '../../domain/entities/project_file.dart';
import '../../domain/repositories/file_system_repository_interface.dart';

/// A repository that interacts with the file system.
class FileSystemRepository implements IFileSystemRepository {
  static const List<String> _ignoredDirs = <String>[
    'build',
    '.dart_tool',
    '.git',
    'ios',
    'android',
    'macos',
    'windows',
    'linux',
    'web',
  ];

  bool _isIgnored(FileSystemEntity entity, String rootPath) {
    final String relative = p.relative(entity.path, from: rootPath);
    final List<String> parts = p.split(relative);
    return parts.any((String part) => _ignoredDirs.contains(part));
  }

  @override
  Future<List<ProjectFile>> findFilesByExtension(String extension) async {
    final Directory currentDir = Directory.current;
    final String rootPath = currentDir.path;
    final List<File> matchedFiles = <File>[];

    await for (final FileSystemEntity entity
        in currentDir.list(recursive: true, followLinks: false)) {
      if (_isIgnored(entity, rootPath)) continue;
      if (entity is File && entity.path.endsWith(extension)) {
        matchedFiles.add(entity);
      }
    }

    return Future.wait(
      matchedFiles.map((File file) async {
        final String content = await file.readAsString();
        return ProjectFile(
          path: p.relative(file.path, from: rootPath),
          content: content,
        );
      }),
    );
  }

  @override
  Future<ProjectFile?> findFileByName(String filename) async {
    final Directory currentDir = Directory.current;

    await for (final FileSystemEntity entity
        in currentDir.list(recursive: true, followLinks: false)) {
      if (_isIgnored(entity, currentDir.path)) continue;
      if (entity is File && entity.path.endsWith(filename)) {
        final String content = await entity.readAsString();
        final String relativePath =
            p.relative(entity.path, from: currentDir.path);
        return ProjectFile(path: relativePath, content: content);
      }
    }

    return null;
  }
}

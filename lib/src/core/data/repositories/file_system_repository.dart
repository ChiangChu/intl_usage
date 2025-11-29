import 'dart:io';

import 'package:path/path.dart' as p;

import '../../domain/entities/project_file.dart';
import '../../domain/repositories/file_system_repository_interface.dart';

/// A repository that interacts with the file system.
class FileSystemRepository implements IFileSystemRepository {
  @override
  Future<List<ProjectFile>> findFilesByExtension(String extension) async {
    final Directory currentDir = Directory.current;
    final List<ProjectFile> files = <ProjectFile>[];

    await for (final FileSystemEntity entity
        in currentDir.list(recursive: true, followLinks: true)) {
      if (entity is File && entity.path.endsWith(extension)) {
        final String content = await entity.readAsString();
        final String relativePath =
            p.relative(entity.path, from: currentDir.path);
        files.add(ProjectFile(path: relativePath, content: content));
      }
    }

    return files;
  }

  @override
  Future<ProjectFile?> findFileByName(String filename) async {
    final Directory currentDir = Directory.current;

    ProjectFile? projectFile;

    await for (final FileSystemEntity entity
        in currentDir.list(recursive: true, followLinks: true)) {
      if (entity is File && entity.path.endsWith(filename)) {
        final String content = await entity.readAsString();
        final String relativePath =
            p.relative(entity.path, from: currentDir.path);
        projectFile = ProjectFile(path: relativePath, content: content);
      }
    }

    return projectFile;
  }
}

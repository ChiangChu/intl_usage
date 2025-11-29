import '../entities/project_file.dart';

// ...
/// An interface for a repository that abstracts file system operations.
///
/// This contract decouples the application from the underlying file system API
/// (like `dart:io`), allowing for easier testing and platform independence.
abstract interface class IFileSystemRepository {
  /// Finds all files in the project that match the given [extension].
  ///
  /// Returns a list of [ProjectFile] objects, each containing the path and
  /// content of a matching file.
  Future<List<ProjectFile>> findFilesByExtension(String extension);

  /// Finds a file in the project by its exact [filename].
  ///
  /// Returns a [ProjectFile] if found, otherwise `null`.
  Future<ProjectFile?> findFileByName(String filename);
}

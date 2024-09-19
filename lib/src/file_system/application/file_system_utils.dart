import 'dart:io';

/// Custom exception indicating that a file or directory was not found.
class FileNotFoundException implements IOException {
  final String message;

  FileNotFoundException({required this.message});
}

///Enumeration representing supported file extensions.
enum FileExtension { dart, json }

/// Utility class for file system operations.
class FileSystemUtils {
  /// Searches for files within a given directory and its subdirectories.
  ///
  /// [relativePath] The path to the directory to search, relative to the current working directory.
  /// [extension] (Optional) The file extension to filter by. If null, all files are returned.
  ///
  /// Returns a list of [FileSystemEntity] objects representing the found files.
  /// Throws a [FileNotFoundException] if the specified directory does not exist.
  Future<List<File>> searchForFiles({
    required String relativePath,
    FileExtension? extension,
  }) async {
    final Directory currentDir = Directory.current;
    final String directoryPath = '${currentDir.path}/$relativePath';
    final Directory dir = Directory(directoryPath);

    if (!await dir.exists()) {
      throw FileNotFoundException(
          message: 'Directory not found: $directoryPath');
    }

    final List<FileSystemEntity> files =
        await dir.list(followLinks: true, recursive: true).toList();

    return files
        .where((FileSystemEntity entity) {
          if (extension == null) return true;
          return entity.path.endsWith('.${extension.name}');
        })
        .map((FileSystemEntity entity) => File(entity.path))
        .toList();
  }
}

/// Represents a file within the project.
class ProjectFile {
  /// The path to the file, relative to the project root.
  final String path;

  /// The content of the file.
  final String content;

  /// Creates a new instance of [ProjectFile].
  ProjectFile({required this.path, required this.content});
}

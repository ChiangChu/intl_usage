/// Represents a single usage of a translation key within a code file.
class UsageEntry {
  /// The name of the file where the translation key is used.
  final String filename;

  /// The line number in the file where the usage occurs.
  final int line;

  /// Indicates whether the usage is considered unsure (e.g., due to dynamic string concatenation).
  final bool isUnsure;

  /// Creates a new [UsageEntry] instance.
  ///
  /// The [filename] and [line] parameters are required.
  /// The [isUnsure] parameter is optional and defaults to `false`.
  UsageEntry({
    required this.filename,
    required this.line,
    this.isUnsure = false,
  });
}

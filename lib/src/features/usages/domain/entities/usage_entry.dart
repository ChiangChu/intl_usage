import 'package:equatable/equatable.dart';

/// Represents a single occurrence of a translation key usage within a file.
///
/// This is a core domain entity that pinpoints the exact location of a usage.
class UsageEntry extends Equatable {
  /// The project-relative path to the file where the usage was found.
  final String filename;

  /// The one-based line number where the usage occurred.
  final int line;

  /// Whether the match is considered uncertain.
  ///
  /// A usage is "unsure" if it's a partial match (e.g., finding `greeting`
  /// in the code when the full key is `greeting.title`).
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

  @override
  List<Object?> get props => <Object>[filename, line, isUnsure];
}

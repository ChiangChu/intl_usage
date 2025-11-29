/// Represents the configuration settings for the application.
class Configuration {
  /// The path to the directory containing translation files.
  ///
  /// Can be null, indicating that a default path will be used.
  final String? path;

  /// The keys to exclude.
  final List<String> exclude;

  /// Creates a [Configuration] object.
  ///
  /// The [path] parameter is optional and specifies the location of
  /// translation files.
  /// The [excludedKeys] parameters can be added to define keys that may
  /// be defined in another package and therefore can't be found inside
  /// the current package. Those will be marked as used.
  Configuration({this.path, this.exclude = const <String>[]});
}

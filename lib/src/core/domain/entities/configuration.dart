/// Represents the configuration settings for the application.
class Configuration {
  /// The path to the directory containing translation files.
  ///
  /// Can be null, indicating that a default path will be used.
  final String? path;

  /// Creates a [Configuration] object.
  ///
  /// The [path] parameter is optional and specifies the location of
  /// translation files.
  Configuration({this.path});
}

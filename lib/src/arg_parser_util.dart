import 'package:args/args.dart';

/// Utility class for creating and managing the command-line argument parser.
class ArgParserUtil {
  /// Constant for the 'help' flag.
  static const String help = 'help';

  /// Constant for the 'path' option.
  static const String path = 'path';

  static const String knownUsedKeys = 'known_used_keys';

  /// The [ArgParser] instance used to parse command-line arguments.
  final ArgParser parser = ArgParser();

  /// Creates a new [ArgParserUtil] and configures the argument parser.
  ArgParserUtil() {
    // Add the 'help' flag to display usage information.
    parser.addFlag(
      help,
      abbr: 'h',
      negatable: false,
      help: 'Displays the usage.',
      defaultsTo: false,
    );

    // Add the 'path' option to specify
    // the directory containing translation files.
    parser.addOption(
      path,
      abbr: 'p',
      defaultsTo: 'assets/translations',
      help: 'define a path to look for translations.',
      valueHelp: 'path',
    );

    // Add the 'known_used_keys' option
    // to specify the keys that are known to be used.
    parser.addOption(
      knownUsedKeys,
      abbr: 'u',
      help: 'define known keys by separating with a comma.',
      valueHelp: 'key1,key2',
    );
  }
}

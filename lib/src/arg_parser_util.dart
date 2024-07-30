import 'package:args/args.dart';

/// Utility class for creating and managing the command-line argument parser.
class ArgParserUtil {
  /// Constant for the 'help' flag.
  static const String help = 'help';

  /// Constant for the 'path' option.
  static const String path = 'path';

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

    // Add the 'path' option to specify the directory containing translation files.
    parser.addOption(
      path,
      abbr: 'p',
      defaultsTo: 'assets/translations',
      help: 'define a path to look for translations.',
      valueHelp: 'path',
    );
  }
}

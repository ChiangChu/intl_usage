import 'dart:core' as dart;

/// A simple logger class for printing messages to the console with optional color formatting.
class Logger {
  /// Prints a message to the console.
  ///
  /// [text] The message to be printed.
  void print(dart.dynamic text) {
    dart.print(text);
  }

  /// Prints a success message in green color to the console.
  ///
  /// [text] The success message to be printed.
  void printSuccess(dart.dynamic text) {
    print('\x1B[32m$text\x1B[0m'); // ANSI escape code for green color
  }

  /// Prints a warning message in yellow color to the console.
  ///
  /// [text] The warning message to be printed.
  void printWarning(dart.dynamic text) {
    print('\x1B[33m$text\x1B[0m'); // ANSI escape code for yellow color
  }

  /// Prints an error message in red color to the console.
  ///
  /// [text] The error message to be printed.
  void printError(dart.dynamic text) {
    print('\x1B[31m$text\x1B[0m'); // ANSI escape code for red color
  }
}

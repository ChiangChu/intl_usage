// ignore: avoid_print
void _consolePrint(Object? text) => print(text);

/// A simple logger class for printing messages to the console with optional color formatting.
class Logger {
  /// Prints a message to the console.
  void print(Object? text) => _consolePrint(text);

  /// Prints a success message in green color to the console.
  void printSuccess(Object? text) {
    print('\x1B[32m$text\x1B[0m');
  }

  /// Prints a warning message in yellow color to the console.
  void printWarning(Object? text) {
    print('\x1B[33m$text\x1B[0m');
  }

  /// Prints an error message in red color to the console.
  void printError(Object? text) {
    print('\x1B[31m$text\x1B[0m');
  }
}

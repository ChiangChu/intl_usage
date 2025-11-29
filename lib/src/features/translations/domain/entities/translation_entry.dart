import 'package:collection/collection.dart';

/// Represents a single, unique translation key and the set of locales
/// in which it has been found.
///
/// This is a core domain entity that represents the aggregated state of a
/// translation key across all translation files.
class TranslationEntry {
  static const SetEquality<String> _setEquality = SetEquality<String>();

  /// The unique key identifying the translation.
  final String key;

  /// A list of locales where this translation is available.
  final Set<String> locales;

  /// Creates a new [TranslationEntry] instance.
  ///
  /// The [key] and [locales] parameters are required.
  TranslationEntry({required this.key, required this.locales});

  /// Creates a copy of this [TranslationEntry] with the given fields replaced.
  ///
  /// If a field is not provided, the original value is retained.
  TranslationEntry copyWith({String? key, Set<String>? locales}) {
    return TranslationEntry(
      key: key ?? this.key,
      locales: locales ?? this.locales,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationEntry &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          _setEquality.equals(other.locales, locales);

  @override
  int get hashCode => key.hashCode ^ locales.hashCode;
}

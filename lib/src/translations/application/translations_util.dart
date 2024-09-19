import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flat/flat.dart';
import 'package:intl_usage/src/translations/domain/translation_entry.dart';
import 'package:path/path.dart';

import '../../file_system/application/file_system_utils.dart';

/// Utility class for handling translation files.
class TranslationsUtil {
  /// Extracts translation entries from JSON files in the specified directory.
  ///
  /// [translationPath] The relative path to the directory containing translation JSON files.
  ///
  /// Returns a list of [TranslationEntry] objects representing the extracted translations.
  Future<List<TranslationEntry>> getTranslations(
    String translationPath, {
    required FileSystemUtils fileSystemUtils,
  }) async {
    List<TranslationEntry> entries = <TranslationEntry>[];

    // Find all JSON files in the translation directory.
    List<File> translationFiles = await fileSystemUtils.searchForFiles(
      relativePath: translationPath,
      extension: FileExtension.json,
    );

    // Regular expression to extract the locale from the filename.
    RegExp regExp = RegExp(r'^[a-zA-Z]{2}(-[a-zA-Z]{2})?\.json$');

    // Iterate through each translation file.
    for (File currentFile in translationFiles) {
      // Check if the filename matches the locale pattern before decoding
      String? localeMatch = regExp.stringMatch(basename(currentFile.path));
      if (localeMatch == null) {
        // No locale found in filename, skip this file.
        continue;
      }

      Map<String, dynamic> json;

      try {
        // Attempt to decode the JSON content of the file.
        json = jsonDecode(currentFile.readAsStringSync());
      } on FormatException {
        // Handle JSON decoding errors by skipping the file.
        continue;
      }

      // Flatten the JSON to extract all key-value pairs.
      Map<String, dynamic> flattenTranslations = flatten(json);

      // Extract the locale from the filename.
      String locale = localeMatch.replaceAll('.json', '');

      // Process each translation key in the file.
      for (String key in flattenTranslations.keys) {
        // Check if a translation entry with the same key already exists.
        TranslationEntry? existingEntry = entries
            .firstWhereOrNull((TranslationEntry entry) => entry.key == key);

        if (existingEntry != null) {
          // Update the existing entry with the new locale.
          existingEntry = existingEntry.copyWith(
            locales: <String>{
              ...existingEntry.locales,
              locale,
            },
          );
          int index = entries.indexWhere(
            (TranslationEntry entry) => entry.key == existingEntry!.key,
          );
          entries[index] = existingEntry;
        } else {
          // Create a new translation entry for the key and locale.
          entries.add(TranslationEntry(key: key, locales: <String>{locale}));
        }
      }
    }

    return entries;
  }

  Map<String, List<String>> findMissingKeys(
      List<TranslationEntry> translations) {
    Map<String, List<String>> missingKeys = {};
    TranslationEntry translationEntryWithAllLocales = translations.reduce(
        (TranslationEntry a, TranslationEntry b) =>
            b.locales.length > a.locales.length ? b : a);

    for (TranslationEntry entry in translations) {
      Set<String> missingLocales =
          translationEntryWithAllLocales.locales.difference(entry.locales);
      for (String missingLocale in missingLocales) {
        missingKeys.putIfAbsent(missingLocale, () => []).add(entry.key);
      }
    }

    return missingKeys;
  }
}

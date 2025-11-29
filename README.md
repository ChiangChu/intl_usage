# Find Unused Translations in Dart/Flutter Projects

[![Pub Version](https://img.shields.io/pub/v/intl_usage.svg)](https://pub.dev/packages/intl_usage)
[![Build Status](https://github.com/ChiangChu/intl_usage/actions/workflows/dart.yml/badge.svg)](https://github.com/ChiangChu/intl_usage/actions)
[![codecov](https://codecov.io/gh/ChiangChu/intl_usage/branch/main/graph/badge.svg?token=YOUR_CODECOV_TOKEN)](https://codecov.io/gh/ChiangChu/intl_usage)

**A Dart package to find unused and missing internationalization (i18n) keys in your project.**

Managing translations in Dart and Flutter projects can become messy over time. Unused keys accumulate,
cluttering your translation files and making maintenance a headache. This package helps you
effortlessly identify and remove unused translation keys, keeping your project clean and efficient.

## Features

* **Identify and remove unused translation keys, reducing clutter and improving project maintainability.**
* **Ensure consistency across all your translation files by detecting missing keys.**

## Installation

Add this to your `pubspec.yaml` file as a dev dependency:

```yaml
dev_dependencies:
  intl_usage: ^1.2.0
```

Then, run:

```bash
  dart pub get
```

## Usage

### Find Unused Keys

To find unused translation keys, run the following command in your project root:

```bash
  dart run intl_usage:find_usages
```

This command scans your project and prints a list of unused translation keys, as well as keys whose
usage is uncertain (e.g., due to dynamic string concatenation).

### Find Missing Keys

To check for missing keys across your translation files, run:

```bash
  dart run intl_usage:check_translations
```

This command reports any keys that are missing in one or more translation files.

### Configuration

You can configure the path to your translation files by creating an `intl_usage.yaml` file in the root of your project:

```yaml
  path: lib/src/assets/translations
```

Alternatively, you can specify the path directly using the `--path` option:

```bash
  dart run intl_usage:find_usages --path lib/src/assets/translations
```

## Limitations

This package is designed to work with JSON translation files. It may not be compatible with other file formats or translation management systems.

## License

This project is licensed under the [MIT License](LICENSE).

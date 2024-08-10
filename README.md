# Find Unused Translations in Flutter Projects

[![Pub Version](https://img.shields.io/pub/v/intl_usage.svg)](https://pub.dev/packages/intl_usage)
[![Build Status](https://github.com/ChiangChu/intl_usage/actions/workflows/dart.yml/badge.svg)](https://github.com/ChiangChu/intl_usage/actions)
[![codecov](https://codecov.io/gh/ChiangChu/intl_usage/branch/main/graph/badge.svg?token=YOUR_CODECOV_TOKEN)](https://codecov.io/gh/ChiangChu/intl_usage)

**This package is used to find unused keys inside your easy_localization files.**
Managing translations in Flutter projects can become messy over time. Unused keys accumulate,
cluttering your translation files and making maintenance a headache. This package helps you
effortlessly identify and remove unused translation keys **specifically in projects using
the `easy_localization` package**, keeping your project clean and efficient.

## Features

* **Effortlessly identify and remove unused translation keys, reducing clutter and improving project
  maintainability.**
* **Ensure consistency across all your translation files by detecting missing keys.**

## Installation

Add this to your `pubspec.yaml` file as a dev dependency:

```yaml
dev_dependencies:
  intl_usage: ^1.0.0
```

Make sure you also have `easy_localization` installed in your project:

```yaml
dependencies:
  easy_localization: ^latest_version
```

```bash
  flutter pub get
```

## Usage

**Find Unused Keys:**

```bash
  dart run intl_usage:find_usages
```

This command scans your project and prints a list of unused translation keys, as well as keys whose
usage is uncertain (e.g., due to dynamic string concatenation).

** Find Missing Keys:**

```bash
  dart run intl_usage:check_translations
```

This command checks your translation files for consistency and reports any keys that are missing in
one or more files.

**Customization Options:**

* **`--path`:** Specifies the path to your translation files. If not provided, the package defaults
  to searching in `assets/translations`. You can also define this path in a YAML configuration
  file (see below).

**Using a YAML Configuration File:**

You can create a `intl_usage.yaml` file in theroot of your project to define the translation path:

```yaml
  path: your/translation/path
```

This eliminates the need to specify the `--path` option every time you run the commands.

## Limitations

Currently, this package only supports translations generated with the `easy_localization`
package.Support for other translation solutions may be added in future releases.

## License

This project is licensed under the [MIT License](LICENSE).

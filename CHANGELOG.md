## [1.2.0] - 2024-09-24

### Added

* `--known_unused_keys` option added as parameter as well as to the configuration file.

### Fixed

* fixed issues with translation keys containing string interpolation.

## [1.1.1] - 2024-09-23

### Fixed

* fixed issues with translation keys containing hyphen or underscore.

## [1.1.0] - 2024-09-19

### Added

* add tests for the functions.
* add path + mocktail library.

### Changed

* refactor for better testability.

### Fixed

* some issues with loading wrong json files.

## [1.0.2] - 2024-08-10

### Changed

* rollback to collection 1.18.0 because flutter_test doesn't support 1.19.0 yet.

### Fixed

* unable to find used keys.

## [1.0.1] - 2024-07-31

### Changed

* Changed packages and pubspec.yaml to fulfill the pub.dev rules.

## [1.0.0] - 2024-07-30

### Added

* add unused translation (this will find unused translation that are not used inside the project).
* add missing translation (find translation keys that are absent in one of the translation files).

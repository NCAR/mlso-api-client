# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog] and this project adheres to
[Semantic Versioning].

## [Unreleased]

## [1.2.0] - 2026-11-16

### Added

- Added interface to access multiple pages of results.
- Added ability to output CSV files from the CLI utility.

### Changed

- Improved speed for simple queries.
- Return exit code indicating type of HTTP status code failure, if not 2xx.
- Better error messages for failures.

### Fixed

- Add default width for environments where the width of the terminal cannot be
  queried for.

## [1.1.2] - 2026-10-08

### Changed

- More docs fixes.

## [1.1.1] - 2026-10-08

### Changed

- Update requirements for publishing docs.

## [1.1.0] - 2026-10-08

### Added

- Add events dataset.
- Allow filtering of other instrument data by events.
- Retrieve different format types, FITS files or quicklooks, for instrument
  data.
- Add info subcommand command-line interface for retrieving information on
  instruments, datasets, and products.

### Changed

- IDL routine `MLSO_FILES` returns a hierarchy of ordered hashes and lists
  instead of an array of structures


## [1.0.0] - 2026-02-26

### Added

- Initial release providing a Python API, a command-line interface, and IDL
  API to access MLSO data via the MLSO API web service.

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html

[Unreleased]: https://github.com/NCAR/mlso-api-client/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/NCAR/mlso-api-client/compare/v1.1.2...v1.2.0
[1.1.2]: https://github.com/NCAR/mlso-api-client/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/NCAR/mlso-api-client/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/NCAR/mlso-api-client/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/NCAR/mlso-api-client/releases/tag/v1.0.0

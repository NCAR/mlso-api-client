# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog] and this project adheres to
[Semantic Versioning].


## [Unreleased]

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

[Unreleased]: https://github.com/NCAR/mlso-api-client/compare/v1.1.1...HEAD
[1.1.0]: https://github.com/NCAR/mlso-api-client/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/NCAR/mlso-api-client/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/NCAR/mlso-api-client/releases/tag/v1.0.0

# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.0]
### Added

- Merged [12](https://github.com/textmaster/faraday_middleware-circuit_breaker/pull/12) which allows to customize the cache key for the circuit breaker

### Changed

- Relaxed version requirement for Faraday to include 2.x

## [0.5.0]

### Changed

- Relaxed version requirement for Stoplight to include 3.0

## [0.4.1]
### Fixed

- Fixed `ArgumentError: Unknown option: data_store. Valid options are :timeout, threshold, fallback, notifiers, data_store,, error_handler`
  due to an extra comma introduced in the valid option list.

## [0.4.0]
### Added

- Handle stoplight custom error handlers. Fixes https://github.com/textmaster/faraday_middleware-circuit_breaker/issues/3

## [0.3.0]
### Added
- Handles stoplight data store

## [0.2.0]
### Added

* Introduces sentry/raven notifier

[Unreleased]: https://github.com/textmaster/faraday_middleware-circuit_breaker/compare/v0.6.0...HEAD
[0.6.0]: https://github.com/textmaster/faraday_middleware-circuit_breaker/compare/v0.4.1...v0.6.0
[0.5.0]: https://github.com/textmaster/faraday_middleware-circuit_breaker/compare/v0.4.1...v0.5.0
[0.4.1]: https://github.com/textmaster/faraday_middleware-circuit_breaker/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/textmaster/faraday_middleware-circuit_breaker/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/textmaster/faraday_middleware-circuit_breaker/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/textmaster/faraday_middleware-circuit_breaker/compare/v0.1.0...v0.2.0
[0.0.1]: https://github.com/textmaster/faraday_middleware-circuit_breaker/releases/tag/v0.1.0

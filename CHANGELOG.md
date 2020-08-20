# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/textmaster/faraday_middleware-circuit_breaker/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/textmaster/faraday_middleware-circuit_breaker/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/textmaster/faraday_middleware-circuit_breaker/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/textmaster/faraday_middleware-circuit_breaker/compare/v0.1.0...v0.2.0
[0.0.1]: https://github.com/textmaster/faraday_middleware-circuit_breaker/releases/tag/v0.1.0

## 1.0.0-dev.13 - 2026-07-22

### 🚀 Features

- Feat: add logging functionality.

### 🐛 Bug Fixes

- Fix(example): update response handling in request detail dialog and adjust dependency overrides

- Fix(example): update response handling in request detail dialog and adjust dependency overrides

### 🚜 Refactor

- Refactor: update class structure of dio network invoker super classes.

- Refactor: rename and restructure network invoker classes for clarity. and introduce logger layer.

- Refactor: update structure of dio network invoker. Using strategy pattern.

- Refactor: remove NullInvokerError and streamline logging in network logger strategy

- Refactor: simplify RawStringBinaryResponse by removing data parameter

- Refactor: streamline CustomNetworkInvoker and enhance logging setup

- Refactor: convert HTTP method names to uppercase in request command logging

- Refactor: enhance DefaultNetworkLogger to include request details in logs

### 📚 Documentation

- Docs: rename receiving files guide and fix links

### 🧪 Testing

- Test: refactor current tests and add tests for missing coverage.

## 1.0.0-dev.12 - 2026-05-12

### 🚀 Features

- Feat: add headers support to response result.

- Feat: implement RequestInvokerMixin for enhanced request handling

## 1.0.0-dev.11 - 2026-05-11

### 🚀 Features

- Feat: add package publishing commands to Makefile

- Feat: enhance result creation logic in mixin_request.dart to handle default responses more robustly

## 1.0.0-dev.10 - 2026-05-09

### 🚀 Features

- Feat: add git push commands for main branch and tags in release process

- Feat: add publish target to Makefile and remove pub.dev publishing from GitHub Actions workflow

## 1.0.0-dev10 - 2026-05-09

### 🚀 Features

- Feat: add toLogString method for improved logging in schema classes

- Feat: add script to update version in pubspec.yaml files and remove existing scripts

- Feat: add script to update changelogs with unreleased changes via git cliff

- Feat: add Makefile with release target for versioning and changelog updates

- Feat: add GitHub Actions workflow for publishing Dart packages and creating releases

### 🚜 Refactor

- Refactor: replace callback setters with explicit methods for request cancellation and result handling

- Refactor: rename request method to send in network invoker and related classes

- Refactor: rename response_result to network_result for clarity

- Refactor: update SuccessResponseResult to extend SpecifiedResponseResult for improved type handling

### 📚 Documentation

- Docs: update README and add new guides for file handling and OpenAPI integration

## 1.0.0-dev9

- Update factories in binary schema.

## 1.0.0-dev8

- Refactor history management.
- Improve binary response handling.

## 1.0.0-dev7

- Fix `meta` dependency constraint changed from `^1.18.1` to `any` to avoid version conflict with Flutter SDK.
- Remove `http_parser` dependency.

## 1.0.0-dev6

- Add binary response support.

## 1.0.0-dev5

- Initial release.

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-10-19

### Added

- CHANGELOG.md and CONTRIBUTE.md to give all required information to contribute to this repository.
- Example configuration file, alert hooks for google chat, icinga2, mail, matrix, slack
  and telegram as initial drafts.
- A systemd unit file with one shot option to setup the script as a service
- The main script `cloudflare_tlsa_sync.sh` itself with the initial release.

### Changed

- Completed the README.md with all required information for releasing the version 1.0.0

[unreleased]: https://github.com/bkuebler/cloudflare-tlsa-sync/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/bkuebler/cloudflare-tlsa-sync/releases/tag/v1.0.0

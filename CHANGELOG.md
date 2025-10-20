# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2025-10-20

### Added

- The generated TLSA record content will now be verified with the expected certificate on the given domain. This helps
  to only update and change TLSA records if the expected new record will work with the given endpoint. The following
  additional parameter in the configuration file `verify_type` was added.
- Description of configuration file was added to the README.md to understand all values better.
- A verify_tlsa.sh script was added for manual testing tlsa records in extras directory.

### Changed

- Internal package dependency handling now more dynamically verified with just a space separated list of commands
  provided in the `COMMANDS` variable.

### Fixed

- Wrongly configured getopts parameters, causes issue in expected execution usage. This was then fixed with the correct
  parameters placed.
- Required command list were not correctly verified. Output of missing installed package were not provided.
- Hash generation for TLSA record type '3 1 1' was wrong. This was now corrected. And works as expected.

## [1.0.0] - 2025-10-19

### Added

- CHANGELOG.md and CONTRIBUTE.md to give all required information to contribute to this repository.
- Example configuration file, alert hooks for google chat, icinga2, mail, matrix, slack and telegram as initial drafts.
- A systemd unit file with one shot option to setup the script as a service.
- The main script `cloudflare_tlsa_sync.sh` itself with the initial release.

### Changed

- Completed the README.md with all required information for releasing the version 1.0.0

[unreleased]: https://github.com/bkuebler/cloudflare-tlsa-sync/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/bkuebler/cloudflare-tlsa-sync/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/bkuebler/cloudflare-tlsa-sync/releases/tag/v1.0.0

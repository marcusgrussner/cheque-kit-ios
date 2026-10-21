# Changelog

All notable changes to ChequeKit are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `CMC7Line(parsing:)` parses the 30 digits of a CMC-7 line into its bank code, branch, clearing code, cheque number, cheque type and account field, and throws `CMC7Line.FormatError` for text that is not a well-formed line.
- `CMC7Reading` checks the three check digits of a CMC-7 line and names the groups whose check digit does not match. An unverified reading keeps the digits as read: ChequeKit never corrects them.
- `ChequeType` gives the kind of cheque, such as ordinary or administrative, and keeps an unrecognised cheque type digit instead of rejecting the line.
- All public types are `Sendable` and `Hashable`.

[Unreleased]: https://github.com/marcusgrussner/cheque-kit/commits/main

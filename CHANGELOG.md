# Changelog

All notable changes to ChequeKit are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- A DocC documentation catalog: a landing page that groups the API by task, and the articles "Reading a cheque photo" and "Verified and unverified readings".

## [0.1.0] - 2026-10-29

### Added

- `CMC7Line(parsing:)` parses the 30 digits of a CMC-7 line into its bank code, branch, clearing code, cheque number, cheque type and account field, and throws `CMC7Line.FormatError` for text that is not a well-formed line.
- `CMC7Reading` checks the three check digits of a CMC-7 line and names the groups whose check digit does not match. An unverified reading keeps the digits as read: ChequeKit never corrects them.
- `ChequeType` gives the kind of cheque, such as ordinary or administrative, and keeps an unrecognised cheque type digit instead of rejecting the line.
- `ChequeReader` reads the CMC-7 line of a cheque in a photo of its front: it finds the cheque, corrects its perspective and decodes the line's bars, trying small rotations until the line passes its check digits at two neighbouring angles. It returns an unverified reading as read when none does, and throws `ChequeReader.ReadError` when the photo shows no cheque or no readable line. Reading needs about 300 dpi across the cheque.
- `CMC7Line`, `CMC7Reading` and `ChequeType` are `Sendable` and `Hashable`, and `ChequeReader` is `Sendable`.

[Unreleased]: https://github.com/marcusgrussner/cheque-kit-ios/compare/0.1.0...HEAD
[0.1.0]: https://github.com/marcusgrussner/cheque-kit-ios/releases/tag/0.1.0

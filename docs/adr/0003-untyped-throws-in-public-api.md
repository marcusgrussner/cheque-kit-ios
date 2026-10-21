# Throw untyped errors from the public API, one error type per operation

Every public ChequeKit operation that can fail declares untyped `throws` and documents its own error type under `- Throws:`; today that is `CMC7Line(parsing:)`, which throws `CMC7Line.FormatError`. Typed throws stays inside the module. This follows [SE-0413](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0413-typed-throws.md), which keeps untyped `throws` as the default and reserves typed throws for code inside a module, generic code that only forwards errors, and constrained environments. The choice is asymmetric: moving a public function from typed to untyped `throws` breaks every host app that switches over its error exhaustively, while the opposite move only raises warnings. `FormatError` is not proven closed yet, since recognising the separator symbols of the CMC-7 line may add cases, and host apps mostly show a parse error rather than handle each case. A single `ChequeKitError` for every operation was rejected: host apps would handle failures of operations they never call, and it would grow with every feature.

## Consequences

- Host apps catch with `catch let error as CMC7Line.FormatError`; code that does not itself throw needs a final `catch`.
- A new case in a public error enum still breaks host apps' exhaustive `switch`, since SwiftPM builds packages without library evolution, so after 1.0 it takes a major version.
- Before 1.0, an error type proven closed may adopt typed throws without breaking host apps, through a new ADR that supersedes this one.

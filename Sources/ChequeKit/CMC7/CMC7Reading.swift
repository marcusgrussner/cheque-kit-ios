/// A CMC-7 line together with the outcome of each of its check digits.
///
/// A reading is verified when all three check digits match. Otherwise it is an unverified
/// reading: the line is still well formed, ``mismatchedGroups`` names the groups whose check
/// digit does not match, and the caller decides what to do with it. A reading never alters
/// the digits to make them match.
public struct CMC7Reading: Sendable, Hashable {
    /// The line this reading evaluates.
    public let line: CMC7Line

    /// The groups whose printed check digit differs from the one computed from the digits it
    /// guards; empty when the reading is verified.
    public let mismatchedGroups: Set<CMC7Line.Group>

    /// Whether all three check digits match.
    public var isVerified: Bool { mismatchedGroups.isEmpty }

    /// Evaluates the three check digits of a line.
    ///
    /// - Parameter line: A well-formed CMC-7 line.
    public init(line: CMC7Line) {
        self.line = line
        mismatchedGroups = Set(
            CMC7Line.Group.allCases.filter { group in
                let checkDigit = line.checkDigit(for: group)
                return CheckDigit.compute(for: checkDigit.guarded) != checkDigit.printed
            }
        )
    }
}

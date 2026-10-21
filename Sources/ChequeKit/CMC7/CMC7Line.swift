/// The 30 digits of a cheque's CMC-7 line, split into its fields.
///
/// A CMC-7 line has three groups of 8, 10 and 12 digits:
///
/// | Group | Positions | Fields |
/// | ----- | --------- | ------ |
/// | 1 | 1–8 | bank code (3), branch (4), check digit (1) |
/// | 2 | 9–18 | clearing code (3), cheque number (6), cheque type (1) |
/// | 3 | 19–30 | check digit (1), account field (10), check digit (1) |
///
/// Parsing checks only the shape of the line: exactly 30 ASCII digits, without separator
/// symbols. It does not validate the check digits, so a well-formed line whose check digits
/// do not match still parses. Code fields are `String` values so they keep their leading
/// zeros; the cheque type is a ``ChequeType``.
struct CMC7Line: Equatable {
    /// The reason a text is not a well-formed CMC-7 line.
    ///
    /// Characters are checked before length, so a text that is both too short and has an
    /// invalid character reports ``invalidCharacter(_:position:)``.
    ///
    /// ```swift
    /// do {
    ///     let line = try CMC7Line(parsing: "12A")
    /// } catch {
    ///     switch error {
    ///     case .invalidCharacter(let character, let position):
    ///         // character == "A", position == 3
    ///     case .invalidLength(let count):
    ///         // ...
    ///     }
    /// }
    /// ```
    enum FormatError: Error, Equatable {
        /// The text contains a character that is not an ASCII digit.
        ///
        /// Non-ASCII digits, such as Arabic-Indic or full-width digits, and separator
        /// symbols are rejected too.
        ///
        /// - Parameters:
        ///   - character: The first offending character.
        ///   - position: The 1-based position of `character` in the text.
        case invalidCharacter(Character, position: Int)

        /// The text has only ASCII digits but not exactly 30 of them.
        ///
        /// - Parameter count: The number of digits the text contains.
        case invalidLength(Int)
    }

    /// One of the three groups of a CMC-7 line.
    ///
    /// Each group is guarded by one check digit, which guards the group's data digits and is
    /// not always printed in the group it guards:
    ///
    /// | Group | Positions | Guarded positions | Check digit position |
    /// | ----- | --------- | ----------------- | -------------------- |
    /// | ``first`` | 1–8 | 1–7 | 19 |
    /// | ``second`` | 9–18 | 9–18 | 8 |
    /// | ``third`` | 19–30 | 20–29 | 30 |
    ///
    /// ```swift
    /// for group in CMC7Line.Group.allCases {
    ///     let (printed, guarded) = line.checkDigit(for: group)
    /// }
    /// ```
    enum Group: CaseIterable {
        /// The 8 digits at positions 1–8: bank code, branch and a check digit.
        case first

        /// The 10 digits at positions 9–18: clearing code, cheque number and cheque type.
        case second

        /// The 12 digits at positions 19–30: a check digit, the account field and a check digit.
        case third
    }

    /// The number of digits in a well-formed CMC-7 line.
    static let length = 30

    private let digits: [Int]

    /// Creates a CMC-7 line by parsing its 30 digits.
    ///
    /// The text must contain exactly ``length`` ASCII digits and nothing else: no
    /// separator symbols, spaces or other characters. The check digits are not validated.
    ///
    /// ```swift
    /// let line = try CMC7Line(parsing: "341067330330018805201725766099")
    /// line.branch  // "0673"
    /// ```
    ///
    /// - Parameter text: The CMC-7 line as plain digits.
    /// - Throws: ``FormatError/invalidCharacter(_:position:)`` for the first character that
    ///   is not an ASCII digit, or ``FormatError/invalidLength(_:)`` when the text has only
    ///   ASCII digits but not exactly ``length`` of them.
    init(parsing text: String) throws(FormatError) {
        var digits: [Int] = []
        for (offset, character) in text.enumerated() {
            guard character.isASCII, let digit = character.wholeNumberValue else {
                throw .invalidCharacter(character, position: offset + 1)
            }
            digits.append(digit)
        }
        guard digits.count == Self.length else {
            throw .invalidLength(digits.count)
        }
        self.digits = digits
    }

    // MARK: - Fields

    var bankCode: String { field(in: 0..<3) }
    var branch: String { field(in: 3..<7) }
    var clearingCode: String { field(in: 8..<11) }
    var chequeNumber: String { field(in: 11..<17) }
    var chequeType: ChequeType { ChequeType(code: digits[17]) }
    var accountField: String { field(in: 19..<29) }

    // MARK: - Check Digits

    /// Returns the check digit printed on the line for a group, and the digits it guards.
    ///
    /// - Parameter group: The group whose check digit to locate.
    /// - Returns: `printed`, the check digit as read from the line, and `guarded`, the digits
    ///   it guards, most significant first. On a line whose check digit matches,
    ///   `CheckDigit.compute(for: guarded) == printed`.
    func checkDigit(for group: Group) -> (printed: Int, guarded: [Int]) {
        switch group {
        case .first: (printed: digits[18], guarded: Array(digits[0..<7]))
        case .second: (printed: digits[7], guarded: Array(digits[8..<18]))
        case .third: (printed: digits[29], guarded: Array(digits[19..<29]))
        }
    }

    // MARK: - Private Methods

    private func field(in range: Range<Int>) -> String {
        digits[range].map(String.init).joined()
    }
}

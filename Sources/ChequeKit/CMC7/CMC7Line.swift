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
/// do not match still parses. Fields are `String` values so they keep their leading zeros.
///
/// ```swift
/// let line = try CMC7Line(parsing: "001123410180001235200001234566")
/// line.bankCode      // "341"
/// line.chequeNumber  // "000123"
/// ```
struct CMC7Line: Equatable {
    /// The reason a text is not a well-formed CMC-7 line.
    ///
    /// Characters are checked before length, so a text that is both too short and has an
    /// invalid character reports ``invalidCharacter(_:position:)``.
    ///
    /// ```swift
    /// do {
    ///     let line = try CMC7Line(parsing: "12A")
    /// } catch .invalidCharacter(let character, let position) {
    ///     // character == "A", position == 3
    /// } catch .invalidLength(let count) {
    ///     // ...
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

    /// The number of digits in a well-formed CMC-7 line.
    static let length = 30

    private let digits: [Int]

    /// Creates a CMC-7 line by parsing its 30 digits.
    ///
    /// The text must contain exactly ``length`` ASCII digits and nothing else: no
    /// separator symbols, spaces or other characters. The check digits are not validated.
    ///
    /// ```swift
    /// let line = try CMC7Line(parsing: "001123410180001235200001234566")
    /// line.branch  // "1234"
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
    var chequeType: String { field(in: 17..<18) }
    var accountField: String { field(in: 19..<29) }

    // MARK: - Private Methods

    private func field(in range: Range<Int>) -> String {
        digits[range].map(String.init).joined()
    }
}

import Testing

@testable import ChequeKit

@Test("Splits a CMC-7 line into its fields")
func parsesLineIntoFields() throws {
    // GIVEN
    let text = "001123410180001235200001234566"

    // WHEN
    let line = try CMC7Line(parsing: text)

    // THEN
    #expect(line.bankCode == "001")
    #expect(line.branch == "1234")
    #expect(line.clearingCode == "018")
    #expect(line.chequeNumber == "000123")
    #expect(line.chequeType == "5")
    #expect(line.accountField == "0000123456")
}

@Test(
    "Rejects a line that does not have 30 digits",
    arguments: [
        ("", 0),
        ("34112343033000123520000123456", 29),  // Itaú line without its last digit
        ("0011234101800012352000012345661", 31),  // Itaú line with an extra digit
    ]
)
func rejectsWrongLength(text: String, count: Int) {
    #expect(throws: CMC7Line.FormatError.invalidLength(count)) {
        try CMC7Line(parsing: text)
    }
}

@Test(
    "Rejects a line with a character that is not an ASCII digit",
    arguments: [
        ("34112343A330001235200001234569", "A", 9),
        ("34112343 0330001235200001234569", " ", 9),  // separators are not accepted yet
        ("٣41123430330001235200001234569", "٣", 1),  // Arabic-Indic digit three
        ("３41123430330001235200001234569", "３", 1),  // full-width digit three
        ("12A", "A", 3),  // characters are checked before length
    ]
)
func rejectsInvalidCharacter(text: String, character: Character, position: Int) {
    #expect(throws: CMC7Line.FormatError.invalidCharacter(character, position: position)) {
        try CMC7Line(parsing: text)
    }
}

// Parsing checks the shape of a line, not its check digits: a well-formed line whose
// check digits do not match still parses, and becomes an unverified reading later.
@Test("Parses a well-formed line even when its check digits do not match")
func parsesLineWithMismatchedCheckDigit() throws {
    // GIVEN the Itaú line with its last check digit changed from 9 to 0
    let text = "341123430330001235200001234560"

    // WHEN
    let line = try CMC7Line(parsing: text)

    // THEN
    #expect(line.accountField == "0000123456")
}

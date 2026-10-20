import Testing

@testable import ChequeKit

@Test("Splits a CMC-7 line into its fields")
func parsesLineIntoFields() throws {
    // GIVEN
    let text = "341067330330018805201725766099"

    // WHEN
    let line = try CMC7Line(parsing: text)

    // THEN
    #expect(line.bankCode == "341")
    #expect(line.branch == "0673")
    #expect(line.clearingCode == "033")
    #expect(line.chequeNumber == "001880")
    #expect(line.chequeType == "5")
    #expect(line.accountField == "0172576609")
}

@Test(
    "Rejects a line that does not have 30 digits",
    arguments: [
        ("", 0),
        ("34106733033001880520172576609", 29),  // Itaú line without its last digit
        ("3410673303300188052017257660991", 31),  // Itaú line with an extra digit
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
        ("34106733A330018805201725766099", "A", 9),
        ("34106733 0330018805201725766099", " ", 9),  // separators are not accepted yet
        ("٣41067330330018805201725766099", "٣", 1),  // Arabic-Indic digit three
        ("３41067330330018805201725766099", "３", 1),  // full-width digit three
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
    let text = "341067330330018805201725766090"

    // WHEN
    let line = try CMC7Line(parsing: text)

    // THEN
    #expect(line.accountField == "0172576609")
}

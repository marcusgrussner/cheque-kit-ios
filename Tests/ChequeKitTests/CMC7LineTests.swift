import Testing

@testable import ChequeKit

struct CMC7LineTests {
    @Test("Splits a CMC-7 line into its fields")
    func parsesLineIntoFields() throws {
        // GIVEN
        let text = Fixtures.specimenLine

        // WHEN
        let line = try CMC7Line(parsing: text)

        // THEN
        #expect(line.bankCode == "001")
        #expect(line.branch == "1234")
        #expect(line.clearingCode == "018")
        #expect(line.chequeNumber == "000123")
        #expect(line.chequeType == .ordinary)
        #expect(line.accountField == "0000123456")
    }

    @Test(
        "Rejects a line that does not have 30 digits",
        arguments: [
            ("", 0),
            (String(Fixtures.specimenLine.dropLast()), 29),
            (Fixtures.specimenLine + "1", 31),
        ]
    )
    func rejectsWrongLength(text: String, count: Int) {
        // WHEN / THEN
        #expect(throws: CMC7Line.FormatError.invalidLength(count)) {
            try CMC7Line(parsing: text)
        }
    }

    @Test(
        "Rejects a line with a character that is not an ASCII digit",
        arguments: [
            (Fixtures.specimenLine.replacing(position: 9, with: "A"), "A", 9),
            (Fixtures.specimenLine.replacing(position: 9, with: " "), " ", 9),  // separators are not accepted yet
            (Fixtures.specimenLine.replacing(position: 1, with: "٣"), "٣", 1),  // Arabic-Indic digit three
            (Fixtures.specimenLine.replacing(position: 1, with: "３"), "３", 1),  // full-width digit three
            ("12A", "A", 3),  // characters are checked before length
        ]
    )
    func rejectsInvalidCharacter(text: String, character: Character, position: Int) {
        // WHEN / THEN
        #expect(throws: CMC7Line.FormatError.invalidCharacter(character, position: position)) {
            try CMC7Line(parsing: text)
        }
    }

    // Parsing checks the shape of a line, not its check digits: a well-formed line whose
    // check digits do not match still parses, and becomes an unverified reading later.
    @Test("Parses a well-formed line even when its check digits do not match")
    func parsesLineWithMismatchedCheckDigit() throws {
        // GIVEN the specimen line with its last check digit misread as 0
        let text = Fixtures.specimenLine.replacing(position: 30, with: "0")

        // WHEN
        let line = try CMC7Line(parsing: text)

        // THEN
        #expect(line.accountField == "0000123456")
    }

    @Test(
        "Locates each check digit and the digits it guards",
        arguments: [
            (.first, 2, [0, 0, 1, 1, 2, 3, 4]),  // position 19 guards positions 1–7
            (.second, 1, [0, 1, 8, 0, 0, 0, 1, 2, 3, 5]),  // position 8 guards positions 9–18
            (.third, 6, [0, 0, 0, 0, 1, 2, 3, 4, 5, 6]),  // position 30 guards positions 20–29
        ] as [(CMC7Line.Group, Int, [Int])]
    )
    func locatesCheckDigit(group: CMC7Line.Group, printed: Int, guarded: [Int]) throws {
        // GIVEN
        let line = try CMC7Line(parsing: Fixtures.specimenLine)

        // WHEN
        let checkDigit = line.checkDigit(for: group)

        // THEN
        #expect(checkDigit.printed == printed)
        #expect(checkDigit.guarded == guarded)
    }
}

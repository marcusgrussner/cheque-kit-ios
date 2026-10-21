import Testing

@testable import ChequeKit

struct CMC7ReadingTests {
    @Test("Verifies a reading whose check digits all match")
    func verifiesMatchingLine() throws {
        // GIVEN
        let line = try CMC7Line(parsing: Fixtures.itauLine)

        // WHEN
        let reading = CMC7Reading(line: line)

        // THEN
        #expect(reading.isVerified)
        #expect(reading.mismatchedGroups.isEmpty)
    }

    @Test(
        "Reports the group whose check digit does not match",
        arguments: [
            (Fixtures.itauLine.replacing(position: 3, with: "2"), .first),  // bank code 341 misread as 342
            (Fixtures.itauLine.replacing(position: 8, with: "2"), .second),  // check digit at position 8 misread
            (Fixtures.itauLine.replacing(position: 30, with: "0"), .third),  // check digit at position 30 misread
        ] as [(String, CMC7Line.Group)]
    )
    func reportsMismatchGroup(text: String, group: CMC7Line.Group) throws {
        // GIVEN
        let line = try CMC7Line(parsing: text)

        // WHEN
        let reading = CMC7Reading(line: line)

        // THEN
        #expect(!reading.isVerified)
        #expect(reading.mismatchedGroups == [group])
    }
}

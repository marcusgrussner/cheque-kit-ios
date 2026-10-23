import Testing

@testable import ChequeKit

struct CMC7DecoderTests {
    @Test(
        "Decodes a character from the pattern of its intervals",
        arguments: [
            ("SSLLSS", "0"), ("LSSSLS", "1"), ("SLLSSS", "2"), ("LSLSSS", "3"), ("LSSLSS", "4"),
            ("SSSLLS", "5"), ("SSLSLS", "6"), ("LLSSSS", "7"), ("SLSSLS", "8"), ("SLSLSS", "9"),
            ("SSLSSL", "<"), ("SSSSLL", ">"), ("LSSSSL", ":"),
        ] as [(String, Character)]
    )
    func decodesCharacter(pattern: String, character: Character) {
        // WHEN
        let decoded = CMC7Decoder.character(intervals: pattern.map { $0 == "L" ? 7 : 3 })

        // THEN
        #expect(decoded == character)
    }

    @Test("Takes the two widest intervals as the long ones")
    func takesWidestIntervalsAsLong() {
        // WHEN
        let decoded = CMC7Decoder.character(intervals: [2, 3, 6, 9, 3, 2])

        // THEN
        #expect(decoded == nil)
    }

    @Test(
        "Decodes nothing from intervals that are not a known character",
        arguments: [
            [3, 3, 7, 7, 3],  // Five intervals.
            [3, 7, 3, 3, 3, 7],  // A pattern no observed character uses.
        ]
    )
    func decodesNothing(intervals: [Int]) {
        // WHEN
        let decoded = CMC7Decoder.character(intervals: intervals)

        // THEN
        #expect(decoded == nil)
    }
}

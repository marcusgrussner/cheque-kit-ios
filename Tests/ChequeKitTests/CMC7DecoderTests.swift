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
        #expect(decoded == "0")
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

    @Test("Decodes a line of bars")
    func decodesLine() {
        // GIVEN
        let bars = SyntheticBars.make("<00112341< 0180001235> 200001234566:")

        // WHEN
        let text = CMC7Decoder.text(bars: bars)

        // THEN
        #expect(text == "<00112341<0180001235>200001234566:")
    }

    @Test("Splits two bars that merged across a short interval")
    func splitsMergedBars() {
        // GIVEN
        var bars = SyntheticBars.make("<00112341<")
        bars[7] = bars[7].lowerBound..<bars[8].upperBound  // The first two bars of the first "0".
        bars.remove(at: 8)

        // WHEN
        let text = CMC7Decoder.text(bars: bars)

        // THEN
        #expect(text == "<00112341<")
    }

    @Test("Marks a character it cannot read")
    func marksUnreadableCharacter() {
        // GIVEN
        var bars = SyntheticBars.make("<00112341<")
        bars.remove(at: 8)  // A bar between two short intervals of the first "0".

        // WHEN
        let text = CMC7Decoder.text(bars: bars)

        // THEN
        #expect(text == "<?0112341<")
    }

    @Test("Decodes nothing from fewer than two bars", arguments: [[], [0..<4]] as [[Range<Int>]])
    func decodesNothingFromFewerThanTwoBars(bars: [Range<Int>]) {
        // WHEN
        let text = CMC7Decoder.text(bars: bars)

        // THEN
        #expect(text.isEmpty)
    }

    @Test("Decodes the line of a flat specimen")
    func decodesFlatSpecimen() throws {
        // GIVEN
        let image = GreyImage(SyntheticSpecimen.make())
        let band = try #require(image.bandRows())

        // WHEN
        let text = CMC7Decoder.text(bars: image.bars(in: band))

        // THEN
        #expect(text == "<00112341<0180001235>200001234566:")
    }
}

@testable import ChequeKit

/// Bars of a CMC-7 line for decoder tests, in pixels: bars 4 wide, intervals of 3 or 7, and 17 between characters.
enum SyntheticBars {
    /// The bars of `text`, where a space widens the gap between two characters, as between groups.
    static func make(_ text: String) -> [Range<Int>] {
        let patternByCharacter = Dictionary(uniqueKeysWithValues: CMC7Decoder.characterByPattern.map { ($1, $0) })
        var bars: [Range<Int>] = []
        var x = 0
        for character in text {
            if character == " " {
                x += 50
                continue
            }
            for interval in patternByCharacter[character]! {
                bars.append(x..<x + 4)
                x += 4 + (interval == "L" ? 7 : 3)
            }
            bars.append(x..<x + 4)
            x += 4 + 17
        }
        return bars
    }
}

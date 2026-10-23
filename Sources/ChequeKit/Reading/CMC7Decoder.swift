/// Decodes the bars of a CMC-7 line into characters.
///
/// Each character is 7 bars with 6 intervals between them, each short or long, and exactly 2 of them long.
enum CMC7Decoder {
    /// The characters by the pattern of their intervals, S for a short interval and L for a long one.
    ///
    /// Derived from real cheques and two patents, as ADR-0004 records; two of the five symbols have not been seen yet.
    static let characterByPattern: [String: Character] = [
        "SSLLSS": "0", "LSSSLS": "1", "SLLSSS": "2", "LSLSSS": "3", "LSSLSS": "4",
        "SSSLLS": "5", "SSLSLS": "6", "LLSSSS": "7", "SLSSLS": "8", "SLSLSS": "9",
        "SSLSSL": "<", "SSSSLL": ">", "LSSSSL": ":",
    ]

    /// Decodes one character from the widths of its six intervals, taking the two widest as the long ones.
    static func character(intervals: [Int]) -> Character? {
        guard intervals.count == 6 else { return nil }
        let longIndices = Set(intervals.indices.sorted { intervals[$0] > intervals[$1] }.prefix(2))
        let pattern = String(intervals.indices.map { longIndices.contains($0) ? "L" : "S" })
        return characterByPattern[pattern]
    }

    /// Decodes the bars of a CMC-7 line, with "?" for a character it cannot read.
    ///
    /// The bars are runs of columns, left to right. A bar much wider than the others is split, because ink can
    /// close a short interval and merge two bars; an interval much wider than a short one ends a character.
    static func text(bars: [Range<Int>]) -> String {
        guard bars.count > 1 else { return "" }
        let barWidth = median(bars.map(\.count))
        let gaps = zip(bars, bars.dropFirst()).map { $1.lowerBound - $0.upperBound }
        let shortGap = median(gaps)

        var intervals: [Int] = []
        for (index, bar) in bars.enumerated() {
            let merged = Double(bar.count + shortGap) / Double(barWidth + shortGap)
            intervals += Array(repeating: shortGap, count: max(1, Int(merged.rounded())) - 1)
            if index < gaps.count { intervals.append(gaps[index]) }
        }

        var characters: [[Int]] = [[]]
        for interval in intervals {
            if interval > 4 * shortGap {
                characters.append([])
            } else {
                characters[characters.count - 1].append(interval)
            }
        }
        return String(characters.map { character(intervals: $0) ?? "?" })
    }

    private static func median(_ values: [Int]) -> Int {
        values.sorted()[values.count / 2]
    }
}

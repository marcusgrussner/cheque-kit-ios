import ChequeKit
import CoreGraphics

/// The CMC-7 characters by the pattern of their six intervals: S for a short interval, L for a long one.
let cmc7Characters: [String: Character] = [
    "SSLLSS": "0", "LSSSLS": "1", "SLLSSS": "2", "LSLSSS": "3", "LSSLSS": "4",
    "SSSLLS": "5", "SSLSLS": "6", "LLSSSS": "7", "SLSSLS": "8", "SLSLSS": "9",
    "SSLSSL": "<", "SSSSLL": ">", "LSSSSL": ":",
]

/// Decodes the bars of a CMC-7 line into its characters, with "?" for a character it cannot read.
func decode(bars: [Range<Int>]) -> String {
    let barWidth = median(bars.map(\.count))
    let gaps = zip(bars, bars.dropFirst()).map { $1.lowerBound - $0.upperBound }
    let shortGap = median(gaps)

    // Intervals between consecutive bars, after splitting bars that merged across a short interval.
    var intervals: [Int] = []
    for (index, bar) in bars.enumerated() {
        let merged = Double(bar.count + shortGap) / Double(barWidth + shortGap)
        intervals += Array(repeating: shortGap, count: max(1, Int(merged.rounded())) - 1)
        if index < gaps.count { intervals.append(gaps[index]) }
    }

    // Characters are separated by intervals much wider than a short one.
    var characters: [[Int]] = [[]]
    for interval in intervals {
        if interval > 4 * shortGap {
            characters.append([])
        } else {
            characters[characters.count - 1].append(interval)
        }
    }
    return String(characters.map { decodeCharacter(intervals: $0) })
}

/// Reads the CMC-7 line of a photo, trying small rotations until the decoded line passes its check digits.
func readLine(in photo: CGImage) throws -> (text: String, degrees: Double)? {
    for step in 0...20 {
        for degrees in step == 0 ? [0] : [Double(step) / 10, -Double(step) / 10] {
            let image = GreyImage(try rotated(photo, byDegrees: degrees))
            let text = decode(bars: findBars(in: image, rows: findBandRows(in: image)))
            let digits = text.filter { $0.isASCII && $0.isNumber }
            if let line = try? CMC7Line(parsing: digits), CMC7Reading(line: line).isVerified {
                return (text, degrees)
            }
        }
    }
    return nil
}

/// Decodes one character from its six intervals, taking the two widest as the long ones.
func decodeCharacter(intervals: [Int]) -> Character {
    guard intervals.count == 6 else { return "?" }
    let longIndices = Set(intervals.indices.sorted { intervals[$0] > intervals[$1] }.prefix(2))
    let pattern = String(intervals.indices.map { longIndices.contains($0) ? "L" : "S" })
    return cmc7Characters[pattern] ?? "?"
}

func median(_ values: [Int]) -> Int {
    values.sorted()[values.count / 2]
}
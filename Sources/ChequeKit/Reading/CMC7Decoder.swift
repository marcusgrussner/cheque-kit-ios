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
}

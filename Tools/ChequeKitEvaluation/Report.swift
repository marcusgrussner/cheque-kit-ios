/// The summary table of an evaluation: one row per variant, in the order the variants were first read.
enum Report {
    static func summary(of reads: [(variant: String, outcome: Outcome, milliseconds: Int)]) -> String {
        var variants: [String] = []
        for read in reads where !variants.contains(read.variant) {
            variants.append(read.variant)
        }

        let header = [
            "variant", "reads", "correct", "false acc.", "unverified", "no cheque", "no line", "median", "p90",
        ]
        let rows = variants.map { variant in
            let ofVariant = reads.filter { $0.variant == variant }
            func count(_ matches: (Outcome) -> Bool) -> String { "\(ofVariant.count { matches($0.outcome) })" }
            let milliseconds = ofVariant.map(\.milliseconds).sorted()
            return [
                variant,
                "\(ofVariant.count)",
                count { $0 == .correct },
                count { if case .falseAccept = $0 { true } else { false } },
                count { if case .unverified = $0 { true } else { false } },
                count { $0 == .chequeNotFound },
                count { $0 == .lineNotFound || $0 == .failed },
                "\(percentile(0.5, of: milliseconds)) ms",
                "\(percentile(0.9, of: milliseconds)) ms",
            ]
        }

        let widths = header.indices.map { column in ([header] + rows).map { $0[column].count }.max()! }
        func format(_ row: [String]) -> String {
            zip(row, widths).enumerated().map { column, cell in
                let padding = String(repeating: " ", count: cell.1 - cell.0.count)
                return column == 0 ? cell.0 + padding : padding + cell.0
            }
            .joined(separator: "  ")
        }
        return ([format(header)] + rows.map(format)).joined(separator: "\n")
    }

    /// The nearest-rank percentile of sorted values, or 0 when there are none.
    private static func percentile(_ fraction: Double, of sorted: [Int]) -> Int {
        guard !sorted.isEmpty else { return 0 }
        let rank = Int((fraction * Double(sorted.count)).rounded(.up))
        return sorted[max(rank, 1) - 1]
    }
}

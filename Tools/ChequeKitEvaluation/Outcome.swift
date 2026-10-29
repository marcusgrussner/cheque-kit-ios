import ChequeKit

/// What reading one photo gave, judged against the line printed on the cheque.
///
/// No case carries the digits of a line, so that a report never shows a real cheque's data.
enum Outcome: Hashable {
    /// The reading passed its check digits and is the printed line.
    case correct

    /// The reading passed its check digits but is not the printed line: the failure a host app cannot detect.
    case falseAccept(differingDigits: Int)

    /// The reading failed its check digits, so a host app knows not to trust it.
    case unverified(differingDigits: Int)

    /// The reader found no cheque in the photo.
    case chequeNotFound

    /// The reader found a cheque but no well-formed line on it.
    case lineNotFound

    /// The photo could not be processed.
    case failed

    /// Judges `reading` against `groundTruth`, the line printed on the cheque.
    init(reading: CMC7Reading, groundTruth: CMC7Line) {
        let differingDigits =
            zip(Self.dataDigits(of: reading.line), Self.dataDigits(of: groundTruth)).count { $0 != $1 }
            + (reading.line.chequeType == groundTruth.chequeType ? 0 : 1)
        if !reading.isVerified {
            self = .unverified(differingDigits: differingDigits)
        } else if reading.line == groundTruth {
            self = .correct
        } else {
            self = .falseAccept(differingDigits: differingDigits)
        }
    }

    /// Judges an error that reading threw.
    init(error: any Error) {
        switch error {
        case ChequeReader.ReadError.chequeNotFound: self = .chequeNotFound
        case ChequeReader.ReadError.lineNotFound: self = .lineNotFound
        default: self = .failed
        }
    }

    /// The outcome's name in reports, with the number of differing digits where there is one.
    var label: String {
        switch self {
        case .correct: "correct"
        case .falseAccept(let digits): "FALSE ACCEPT (\(digits) data digits differ)"
        case .unverified(let digits): "unverified (\(digits) data digits differ)"
        case .chequeNotFound: "no cheque"
        case .lineNotFound: "no line"
        case .failed: "failed"
        }
    }

    // The public API exposes a line's fields but not its check digits, so the count covers the 26 data digits: these
    // code fields and, in `init`, the cheque type.
    private static func dataDigits(of line: CMC7Line) -> [Character] {
        Array(line.bankCode + line.branch + line.clearingCode + line.chequeNumber + line.accountField)
    }
}

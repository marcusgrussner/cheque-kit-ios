/// The kind of cheque, encoded by the cheque type digit of a CMC-7 line.
///
/// The codes come from BCB Circular 1.976/1991. A code outside that list does not make a
/// line unreadable: it becomes ``unrecognized(_:)`` and keeps the digit as read, so a new or
/// unexpected code is reported instead of rejected.
public enum ChequeType: Sendable, Hashable {
    /// An ordinary cheque, code 5.
    case ordinary

    /// A payment order cheque, code 6.
    case paymentOrder

    /// A traveller's cheque, code 7.
    case travellers

    /// An administrative cheque, issued by the bank itself, code 8.
    case administrative

    /// A code that no known cheque type uses.
    ///
    /// - Parameter code: The cheque type digit as read from the line.
    case unrecognized(Int)

    /// Creates the cheque type for a cheque type digit.
    ///
    /// - Parameter code: The cheque type digit, at position 18 of a CMC-7 line.
    init(code: Int) {
        switch code {
        case 5: self = .ordinary
        case 6: self = .paymentOrder
        case 7: self = .travellers
        case 8: self = .administrative
        default: self = .unrecognized(code)
        }
    }
}

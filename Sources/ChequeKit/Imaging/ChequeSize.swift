import CoreGraphics

/// The physical size of a cheque, in millimetres.
enum ChequeSize {
    static let width: CGFloat = 175
    static let height: CGFloat = 75
    static let aspectRatio = width / height
}

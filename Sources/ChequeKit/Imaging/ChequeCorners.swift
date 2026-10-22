import CoreGraphics

/// The four corners of a cheque in an image, in pixels, with the origin at the image's bottom-left corner.
///
/// Vision and Core Image place the origin there too, so corners pass between them without flipping.
struct ChequeCorners: Equatable, Sendable {
    let topLeft: CGPoint
    let topRight: CGPoint
    let bottomRight: CGPoint
    let bottomLeft: CGPoint
}

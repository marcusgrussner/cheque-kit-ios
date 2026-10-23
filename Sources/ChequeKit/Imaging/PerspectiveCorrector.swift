import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins

/// Turns the cheque in a photo into a straight, upright image with a cheque's proportions.
enum PerspectiveCorrector {
    /// The reason a cheque could not be corrected.
    enum CorrectionError: Error {
        case renderingFailed
    }

    /// Returns the cheque inside `corners`, as wide as its top and bottom edges on average and as tall as a cheque
    /// of that width.
    static func corrected(_ image: CGImage, corners: ChequeCorners) throws(CorrectionError) -> CGImage {
        let filter = CIFilter.perspectiveCorrection()
        filter.inputImage = CIImage(cgImage: image)
        filter.topLeft = corners.topLeft
        filter.topRight = corners.topRight
        filter.bottomRight = corners.bottomRight
        filter.bottomLeft = corners.bottomLeft
        guard let straight = filter.outputImage else { throw .renderingFailed }

        let topEdge = distance(corners.topLeft, corners.topRight)
        let bottomEdge = distance(corners.bottomLeft, corners.bottomRight)
        let width = ((topEdge + bottomEdge) / 2).rounded()
        let height = (width / ChequeSize.aspectRatio).rounded()
        let toOrigin = CGAffineTransform(translationX: -straight.extent.minX, y: -straight.extent.minY)
        let toSize = CGAffineTransform(scaleX: width / straight.extent.width, y: height / straight.extent.height)
        let fitted = straight.transformed(by: toOrigin.concatenating(toSize))
        guard let corrected = context.createCGImage(fitted, from: CGRect(x: 0, y: 0, width: width, height: height))
        else { throw .renderingFailed }
        return corrected
    }

    private static let context = CIContext()

    private static func distance(_ start: CGPoint, _ end: CGPoint) -> CGFloat {
        hypot(end.x - start.x, end.y - start.y)
    }
}

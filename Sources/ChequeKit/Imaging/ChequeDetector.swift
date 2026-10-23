import CoreGraphics
import Vision

/// Finds a cheque in a photo.
enum ChequeDetector {
    /// Returns the corners of the most prominent cheque-shaped rectangle in `image`, or `nil` when there is none.
    ///
    /// An image cropped to the cheque has no edges to find, so an image with a cheque's shape is taken whole.
    static func corners(in image: CGImage) throws -> ChequeCorners? {
        let request = VNDetectRectanglesRequest()
        // Short side over long side: a cheque is 75 / 175 ≈ 0.43.
        request.minimumAspectRatio = 0.3
        request.maximumAspectRatio = 0.6
        request.quadratureTolerance = 30
        request.minimumSize = 0.2
        try VNImageRequestHandler(cgImage: image).perform([request])

        let width = CGFloat(image.width)
        let height = CGFloat(image.height)
        guard let observation = request.results?.first else {
            guard abs(width / height - ChequeSize.aspectRatio) < 0.1 * ChequeSize.aspectRatio else { return nil }
            return ChequeCorners(
                topLeft: CGPoint(x: 0, y: height),
                topRight: CGPoint(x: width, y: height),
                bottomRight: CGPoint(x: width, y: 0),
                bottomLeft: .zero
            )
        }

        func pixels(_ point: CGPoint) -> CGPoint {
            CGPoint(x: point.x * width, y: point.y * height)
        }

        return ChequeCorners(
            topLeft: pixels(observation.topLeft),
            topRight: pixels(observation.topRight),
            bottomRight: pixels(observation.bottomRight),
            bottomLeft: pixels(observation.bottomLeft)
        )
    }
}

import CoreGraphics

@testable import ChequeKit

/// Photos for imaging tests: a plain cheque-shaped card on a uniform background.
enum SyntheticPhoto {
    static let size = CGSize(width: 2000, height: 1600)

    /// Draws a photo with a cheque at the given corners, or an empty background when `cheque` is `nil`.
    static func make(cheque: ChequeCorners?, background: CGFloat = 0.2) -> CGImage {
        let context = CGContext(
            data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
        context.setFillColor(gray: background, alpha: 1)
        context.fill(CGRect(origin: .zero, size: size))
        if let cheque {
            context.setFillColor(red: 0.85, green: 0.88, blue: 0.95, alpha: 1)
            context.addLines(between: [cheque.topLeft, cheque.topRight, cheque.bottomRight, cheque.bottomLeft])
            context.closePath()
            context.fillPath()
        }
        return context.makeImage()!
    }
}

extension ChequeCorners {
    /// The largest distance, in pixels, between a corner and the matching corner of `other`.
    func maximumDistance(to other: ChequeCorners) -> CGFloat {
        zip(
            [topLeft, topRight, bottomRight, bottomLeft],
            [other.topLeft, other.topRight, other.bottomRight, other.bottomLeft]
        )
        .map { hypot($0.x - $1.x, $0.y - $1.y) }
        .max()!
    }
}

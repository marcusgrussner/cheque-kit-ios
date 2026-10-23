import CoreGraphics

@testable import ChequeKit

/// Photos for imaging tests: a plain cheque-shaped card on a uniform background.
enum SyntheticPhoto {
    /// Draws a photo with a cheque at the given corners, or an empty background when `cheque` is `nil`.
    ///
    /// A `marked` cheque carries a dark mark near its top-left corner, to tell which way up it is.
    static func make(
        cheque: ChequeCorners?, background: CGFloat = 0.2, size: CGSize = CGSize(width: 2000, height: 1600),
        marked: Bool = false
    ) -> CGImage {
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
            if marked {
                context.setFillColor(gray: 0, alpha: 1)
                context.addLines(between: [
                    cheque.point(across: 0.05, down: 0.1), cheque.point(across: 0.1, down: 0.1),
                    cheque.point(across: 0.1, down: 0.2), cheque.point(across: 0.05, down: 0.2),
                ])
                context.closePath()
                context.fillPath()
            }
        }
        return context.makeImage()!
    }
}

extension ChequeCorners {
    /// The point `across` of the way from the left edge and `down` of the way from the top edge, by bilinear
    /// interpolation between the corners.
    func point(across: CGFloat, down: CGFloat) -> CGPoint {
        let top = CGPoint(
            x: topLeft.x + (topRight.x - topLeft.x) * across, y: topLeft.y + (topRight.y - topLeft.y) * across)
        let bottom = CGPoint(
            x: bottomLeft.x + (bottomRight.x - bottomLeft.x) * across,
            y: bottomLeft.y + (bottomRight.y - bottomLeft.y) * across)
        return CGPoint(x: top.x + (bottom.x - top.x) * down, y: top.y + (bottom.y - top.y) * down)
    }

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

extension CGImage {
    /// The grey level, from 0 (black) to 1 (white), at the point `across` of the way from the left edge and `down`
    /// of the way from the top edge.
    func greyLevel(across: CGFloat, down: CGFloat) -> CGFloat {
        var pixels = [UInt8](repeating: 0, count: width * height)
        pixels.withUnsafeMutableBytes { buffer in
            let context = CGContext(
                data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width,
                space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue)
            context?.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        let x = Int(across * CGFloat(width - 1))
        let y = Int(down * CGFloat(height - 1))
        return CGFloat(pixels[y * width + x]) / 255
    }
}

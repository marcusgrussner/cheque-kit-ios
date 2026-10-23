import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins

@testable import ChequeKit

/// A synthetic cheque specimen whose CMC-7 line is drawn bar by bar from the decoder's table.
///
/// The bars follow the proportions measured on real cheques: 0.2 mm wide, intervals of 0.15 or 0.4 mm, 0.9 mm
/// between characters and 2 mm more between groups, 3 mm tall and 4 mm above the bottom edge.
enum SyntheticSpecimen {
    /// Draws a flat specimen whose CMC-7 line holds `digits`, at `scale` pixels per millimetre.
    static func make(digits: String = Fixtures.specimenLine, scale: CGFloat = 18) -> CGImage {
        let context = CGContext(
            data: nil, width: Int(ChequeSize.width * scale), height: Int(ChequeSize.height * scale),
            bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
        context.scaleBy(x: scale, y: scale)  // From here on, draw in millimetres.
        context.setFillColor(red: 0.85, green: 0.88, blue: 0.95, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: ChequeSize.width, height: ChequeSize.height))
        context.setFillColor(gray: 0.1, alpha: 1)

        // Printed lines above the CMC-7 line, which the band search must skip.
        for bottom: CGFloat in [14, 18, 22] {
            context.fill(CGRect(x: 8, y: bottom, width: 60, height: 2))
        }

        let patternByCharacter = Dictionary(uniqueKeysWithValues: CMC7Decoder.characterByPattern.map { ($1, $0) })
        let groups = (digits.prefix(8), digits.dropFirst(8).prefix(10), digits.suffix(12))
        var x: CGFloat = 8
        for character in "<\(groups.0)< \(groups.1)> \(groups.2):" {
            if character == " " {
                x += 2
                continue
            }
            context.fill(CGRect(x: x, y: 4, width: 0.2, height: 3))
            for interval in patternByCharacter[character]! {
                x += 0.2 + (interval == "L" ? 0.4 : 0.15)
                context.fill(CGRect(x: x, y: 4, width: 0.2, height: 3))
            }
            x += 0.2 + 0.9
        }
        return context.makeImage()!
    }

    /// Photographs `specimen` on a dark grey background of `size`, with its corners at `corners`.
    static func photo(of specimen: CGImage, at corners: ChequeCorners, size: CGSize) -> CGImage {
        let filter = CIFilter.perspectiveTransform()
        filter.inputImage = CIImage(cgImage: specimen)
        filter.topLeft = corners.topLeft
        filter.topRight = corners.topRight
        filter.bottomRight = corners.bottomRight
        filter.bottomLeft = corners.bottomLeft
        let background = CIImage(color: CIColor(red: 0.2, green: 0.2, blue: 0.2))
            .cropped(to: CGRect(origin: .zero, size: size))
        return CIContext().createCGImage(filter.outputImage!.composited(over: background), from: background.extent)!
    }
}

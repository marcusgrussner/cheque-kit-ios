import UIKit

extension UIImage {
    /// The image's pixels turned the way the photo is shown, since cameras often store them sideways with an
    /// orientation flag.
    func uprightCGImage() -> CGImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in draw(at: .zero) }.cgImage
    }
}

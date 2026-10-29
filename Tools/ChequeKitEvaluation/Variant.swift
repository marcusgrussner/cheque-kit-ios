import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins

/// A degradation applied to a photo before it is read, to find how far the reader holds up.
enum Variant: Hashable, CustomStringConvertible {
    /// The photo as taken.
    case original

    /// The photo scaled down by `factor`, as a camera with fewer pixels across the cheque would take it.
    case scaled(Double)

    /// The photo rotated by `degrees`, counter-clockwise, as a cheque held at a slant.
    case rotated(Double)

    /// The photo darkened or lightened by `stops`, as a cheque in dim or bright light.
    case exposed(Double)

    /// The photo blurred by a Gaussian of `radius` pixels, as a cheque slightly out of focus.
    case blurred(Double)

    /// The variants a full evaluation reads every photo in.
    static let all: [Variant] = [
        .original,
        .scaled(0.75), .scaled(0.5), .scaled(0.35),
        .rotated(-3), .rotated(-1), .rotated(1), .rotated(3),
        .exposed(-1.5), .exposed(1),
        .blurred(1.5), .blurred(3),
    ]

    var description: String {
        switch self {
        case .original: "original"
        case .scaled(let factor): "scaled \(factor)×"
        case .rotated(let degrees): "rotated \(degrees)°"
        case .exposed(let stops): "exposed \(stops > 0 ? "+" : "")\(stops) EV"
        case .blurred(let radius): "blurred \(radius) px"
        }
    }

    /// Returns `image` with this degradation applied.
    func apply(to image: CGImage) -> CGImage {
        let input = CIImage(cgImage: image)
        let output: CIImage
        switch self {
        case .original:
            return image
        case .scaled(let factor):
            let filter = CIFilter.lanczosScaleTransform()
            filter.inputImage = input
            filter.scale = Float(factor)
            output = filter.outputImage!
        case .rotated(let degrees):
            // Rotate about the centre and keep the original frame, filling the uncovered corners with dark grey as a
            // table would.
            let centre = CGAffineTransform(translationX: input.extent.midX, y: input.extent.midY)
            let rotation = centre.rotated(by: degrees * .pi / 180).translatedBy(
                x: -input.extent.midX, y: -input.extent.midY)
            let background = CIImage(color: CIColor(red: 0.2, green: 0.2, blue: 0.2)).cropped(to: input.extent)
            output = input.transformed(by: rotation).composited(over: background).cropped(to: input.extent)
        case .exposed(let stops):
            let filter = CIFilter.exposureAdjust()
            filter.inputImage = input
            filter.ev = Float(stops)
            output = filter.outputImage!
        case .blurred(let radius):
            let filter = CIFilter.gaussianBlur()
            filter.inputImage = input.clampedToExtent()
            filter.radius = Float(radius)
            output = filter.outputImage!.cropped(to: input.extent)
        }
        let extent = output.extent.integral
        return Self.context.createCGImage(output, from: extent)!
    }

    private static let context = CIContext()
}

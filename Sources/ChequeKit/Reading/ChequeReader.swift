import CoreGraphics

/// Reads the CMC-7 line of a cheque in a photo.
///
/// ```swift
/// let reading = try await ChequeReader().read(photo)
/// if reading.isVerified {
///     // All three check digits match.
/// }
/// ```
public struct ChequeReader: Sendable {
    /// The reason a photo could not be read.
    public enum ReadError: Error, Hashable {
        /// The photo shows no cheque.
        case chequeNotFound

        /// The photo shows a cheque, but no well-formed CMC-7 line could be read on it.
        case lineNotFound
    }

    /// Creates a reader.
    public init() {}

    /// Reads the CMC-7 line of the cheque in a photo.
    ///
    /// The reader finds the cheque, straightens it and decodes its CMC-7 line, trying small rotations until the line
    /// passes its check digits. When no rotation gives a verified reading, it returns the first unverified reading as
    /// read, never correcting a digit, and the host app decides what to do with it.
    ///
    /// The work runs off the caller's actor, so calling it from the main actor does not block the interface.
    ///
    /// - Parameter photo: A photo of the front of a cheque, at about 300 dpi or more across the cheque.
    /// - Returns: The CMC-7 reading, verified or unverified.
    /// - Throws: ``ReadError/chequeNotFound`` when the photo shows no cheque, ``ReadError/lineNotFound`` when no
    ///   well-formed line can be read, or the error of Vision or Core Image when the photo cannot be processed.
    @concurrent
    public func read(_ photo: CGImage) async throws -> CMC7Reading {
        guard let corners = try ChequeDetector.corners(in: photo) else { throw ReadError.chequeNotFound }
        let cheque = try PerspectiveCorrector.corrected(photo, corners: corners)

        var unverified: CMC7Reading?
        for degrees in Self.angles {
            let image = GreyImage(Self.rotated(cheque, byDegrees: degrees))
            guard let band = image.bandRows() else { continue }
            let digits = CMC7Decoder.text(bars: image.bars(in: band)).filter { $0.isASCII && $0.isNumber }
            guard let line = try? CMC7Line(parsing: digits) else { continue }
            let reading = CMC7Reading(line: line)
            if reading.isVerified { return reading }
            if unverified == nil { unverified = reading }
        }
        guard let unverified else { throw ReadError.lineNotFound }
        return unverified
    }

    // MARK: - Skew

    /// No rotation first, then ±0.1° up to ±2°, smallest first.
    private static let angles: [Double] = [0] + (1...20).flatMap { [Double($0) / 10, -Double($0) / 10] }

    private static func rotated(_ image: CGImage, byDegrees degrees: Double) -> CGImage {
        let width = CGFloat(image.width)
        let height = CGFloat(image.height)
        guard degrees != 0,
            let context = CGContext(
                data: nil, width: image.width, height: image.height, bitsPerComponent: 8, bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue)
        else { return image }
        context.setFillColor(gray: 1, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.interpolationQuality = .high
        context.translateBy(x: width / 2, y: height / 2)
        context.rotate(by: degrees * .pi / 180)
        context.draw(image, in: CGRect(x: -width / 2, y: -height / 2, width: width, height: height))
        return context.makeImage() ?? image
    }
}

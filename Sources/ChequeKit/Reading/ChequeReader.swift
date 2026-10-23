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
    /// passes its check digits at two neighbouring angles. When no rotation gives such a reading, it returns the first
    /// unverified reading as read, never correcting a digit, and the host app decides what to do with it.
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
        let corrected = try PerspectiveCorrector.corrected(photo, corners: corners)
        // Detected corners can sit a few pixels outside the cheque: trim 1% of each edge so that no background is left
        // for a rotation to slant into the band.
        let bounds = CGRect(x: 0, y: 0, width: corrected.width, height: corrected.height)
        let cheque =
            corrected.cropping(to: bounds.insetBy(dx: bounds.width / 100, dy: bounds.height / 100)) ?? corrected

        let reading = Self.agreedReading { tenths in
            let image = GreyImage(Self.rotated(cheque, byDegrees: Double(tenths) / 10))
            guard let band = image.bandRows() else { return nil }
            let digits = CMC7Decoder.text(bars: image.bars(in: band)).filter { $0.isASCII && $0.isNumber }
            return (try? CMC7Line(parsing: digits)).map { CMC7Reading(line: $0) }
        }
        guard let reading else { throw ReadError.lineNotFound }
        return reading
    }

    // MARK: - Skew

    /// Searches rotations for a verified reading that a neighbouring rotation confirms, or else the first unverified
    /// reading.
    ///
    /// Each verified reading the search finds was one more chance for a misread to pass the check digits, so a
    /// verified reading counts only when the rotation 0.1° beside it reads the same line.
    ///
    /// - Parameter reading: The reading of the cheque rotated by a number of tenths of a degree, if any.
    /// - Returns: The first confirmed verified reading, else the first unverified reading, else `nil`.
    static func agreedReading(_ reading: (_ tenths: Int) -> CMC7Reading?) -> CMC7Reading? {
        var cache: [Int: CMC7Reading?] = [:]
        func cachedReading(_ tenths: Int) -> CMC7Reading? {
            if let known = cache[tenths] { return known }
            let new = reading(tenths)
            cache[tenths] = new
            return new
        }

        var unverified: CMC7Reading?
        for tenths in [0] + (1...20).flatMap({ [$0, -$0] }) {
            guard let candidate = cachedReading(tenths) else { continue }
            if candidate.isVerified {
                if [tenths - 1, tenths + 1].contains(where: { cachedReading($0) == candidate }) { return candidate }
            } else if unverified == nil {
                unverified = candidate
            }
        }
        return unverified
    }

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

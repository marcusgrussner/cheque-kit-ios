import CoreGraphics

/// A grey copy of an image for finding the CMC-7 line: one byte per pixel, from 0 (black) to 255 (white), rows from
/// the top.
struct GreyImage {
    let width: Int
    let height: Int
    private let pixels: [UInt8]

    init(_ image: CGImage) {
        width = image.width
        height = image.height
        var pixels = [UInt8](repeating: 255, count: image.width * image.height)
        pixels.withUnsafeMutableBytes { buffer in
            let context = CGContext(
                data: buffer.baseAddress, width: image.width, height: image.height, bitsPerComponent: 8,
                bytesPerRow: image.width, space: CGColorSpaceCreateDeviceGray(),
                bitmapInfo: CGImageAlphaInfo.none.rawValue)
            context?.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        }
        self.pixels = pixels
    }

    /// The rows of the CMC-7 line: the lowest run of rows that look like printed text, or `nil` when there is none.
    ///
    /// A row looks like printed text when ink covers more than 5% of it and less than 60%; a solid strip, such as
    /// background left at the edge of a cheque, does not.
    func bandRows() -> ClosedRange<Int>? {
        func isTextRow(_ y: Int) -> Bool {
            let ink = Double((0..<width).count { isInk(x: $0, y: y) }) / Double(width)
            return ink > 0.05 && ink < 0.6
        }
        var bottom = height - 1
        while bottom >= 0, !isTextRow(bottom) { bottom -= 1 }
        guard bottom >= 0 else { return nil }
        var top = bottom
        while top > 0, isTextRow(top - 1) { top -= 1 }
        return top...bottom
    }

    /// The bars across `rows`, left to right: runs of columns where ink covers more than 35% of the rows.
    func bars(in rows: ClosedRange<Int>) -> [Range<Int>] {
        var bars: [Range<Int>] = []
        var start: Int?
        for x in 0...width {
            let ink = x < width ? Double(rows.count { isInk(x: x, y: $0) }) / Double(rows.count) : 0
            if ink > 0.35, start == nil { start = x }
            if ink <= 0.35, let barStart = start {
                bars.append(barStart..<x)
                start = nil
            }
        }
        return bars
    }

    private func isInk(x: Int, y: Int) -> Bool {
        pixels[y * width + x] < 100
    }
}

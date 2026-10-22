import CoreGraphics

/// A grey copy of an image: one byte per pixel, from 0 (black) to 255 (white), rows from the top.
struct GreyImage {
    let width: Int
    let height: Int
    let pixels: [UInt8]

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

    func isInk(x: Int, y: Int) -> Bool {
        pixels[y * width + x] < 100
    }
}

/// The rows of the CMC-7 line: the lowest run of rows where ink covers more than 5% of the row,
/// or `nil` when no row does.
func findBandRows(in image: GreyImage) -> ClosedRange<Int>? {
    func isInkRow(_ y: Int) -> Bool {
        let ink = (0..<image.width).count { x in image.isInk(x: x, y: y) }
        return Double(ink) / Double(image.width) > 0.05
    }
    var bottom = image.height - 1
    while bottom >= 0, !isInkRow(bottom) { bottom -= 1 }
    guard bottom >= 0 else { return nil }
    var top = bottom
    while top > 0, isInkRow(top - 1) { top -= 1 }
    return top...bottom
}

/// The bars of the CMC-7 line: runs of columns where ink covers more than 35% of the band's rows.
func findBars(in image: GreyImage, rows: ClosedRange<Int>) -> [Range<Int>] {
    var bars: [Range<Int>] = []
    var start: Int?
    for x in 0...image.width {
        let ink = x < image.width ? rows.count { y in image.isInk(x: x, y: y) } : 0
        let isBar = Double(ink) / Double(rows.count) > 0.35
        if isBar, start == nil { start = x }
        if !isBar, let barStart = start {
            bars.append(barStart..<x)
            start = nil
        }
    }
    return bars
}
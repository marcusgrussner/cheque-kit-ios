import CoreGraphics
import Testing

@testable import ChequeKit

struct GreyImageTests {
    @Test("Finds the lowest band of printed rows")
    func findsLowestBand() {
        // GIVEN
        let image = Self.image(ink: Self.band(rows: 40..<61) + Self.band(rows: 150..<171))

        // WHEN
        let rows = image.bandRows()

        // THEN
        #expect(rows == 150...170)
    }

    @Test("Skips a solid strip below the band")
    func skipsSolidStrip() {
        // GIVEN
        let strip = CGRect(x: 0, y: 190, width: 400, height: 10)
        let image = Self.image(ink: Self.band(rows: 150..<171) + [strip])

        // WHEN
        let rows = image.bandRows()

        // THEN
        #expect(rows == 150...170)
    }

    @Test("Finds a band that reaches the top edge")
    func findsBandAtTopEdge() {
        // GIVEN
        let image = Self.image(ink: Self.band(rows: 0..<31))

        // WHEN
        let rows = image.bandRows()

        // THEN
        #expect(rows == 0...30)
    }

    @Test("Finds no band in a blank image")
    func findsNoBand() {
        // GIVEN
        let image = Self.image(ink: [])

        // WHEN
        let rows = image.bandRows()

        // THEN
        #expect(rows == nil)
    }

    @Test("Finds the bars of a band")
    func findsBars() {
        // GIVEN
        let image = Self.image(ink: Self.band(rows: 150..<171))

        // WHEN
        let bars = image.bars(in: 150...170)

        // THEN
        #expect(bars == (0..<30).map { 20 + 12 * $0..<24 + 12 * $0 })
    }

    // MARK: - Drawing

    /// A white 400 × 200 image with black rectangles, in pixels from the top-left corner.
    private static func image(ink rectangles: [CGRect]) -> GreyImage {
        let context = CGContext(
            data: nil, width: 400, height: 200, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue)!
        context.setFillColor(gray: 1, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: 400, height: 200))
        context.setFillColor(gray: 0, alpha: 1)
        for rectangle in rectangles {
            // Core Graphics draws from the bottom-left corner.
            context.fill(
                CGRect(x: rectangle.minX, y: 200 - rectangle.maxY, width: rectangle.width, height: rectangle.height))
        }
        return GreyImage(context.makeImage()!)
    }

    /// Thirty bars 4 px wide, 12 px apart from x = 20, across `rows`.
    private static func band(rows: Range<Int>) -> [CGRect] {
        (0..<30).map { CGRect(x: 20 + 12 * $0, y: rows.lowerBound, width: 4, height: rows.count) }
    }
}

import CoreGraphics
import Testing

@testable import ChequeKit

struct PerspectiveCorrectorTests {
    @Test("Corrects a cheque in perspective to a cheque's proportions")
    func correctsToChequeProportions() throws {
        // GIVEN
        let cheque = ChequeCorners(
            topLeft: CGPoint(x: 380, y: 980), topRight: CGPoint(x: 1620, y: 1040),
            bottomRight: CGPoint(x: 1760, y: 350), bottomLeft: CGPoint(x: 240, y: 420))
        let photo = SyntheticPhoto.make(cheque: cheque)

        // WHEN
        let corrected = try PerspectiveCorrector.corrected(photo, corners: cheque)

        // THEN
        // The top edge is 1241 px long and the bottom edge 1522 px: 1382 px wide on average, and 1382 / (175 / 75) ≈ 592.
        #expect(corrected.width == 1382)
        #expect(corrected.height == 592)
    }

    @Test("Keeps the cheque upright")
    func keepsChequeUpright() throws {
        // GIVEN
        let cheque = ChequeCorners(
            topLeft: CGPoint(x: 380, y: 980), topRight: CGPoint(x: 1620, y: 1040),
            bottomRight: CGPoint(x: 1760, y: 350), bottomLeft: CGPoint(x: 240, y: 420))
        let photo = SyntheticPhoto.make(cheque: cheque, marked: true)

        // WHEN
        let corrected = try PerspectiveCorrector.corrected(photo, corners: cheque)

        // THEN
        #expect(corrected.greyLevel(across: 0.075, down: 0.15) < 0.5)
        #expect(corrected.greyLevel(across: 0.925, down: 0.15) > 0.5)
        #expect(corrected.greyLevel(across: 0.075, down: 0.85) > 0.5)
    }
}

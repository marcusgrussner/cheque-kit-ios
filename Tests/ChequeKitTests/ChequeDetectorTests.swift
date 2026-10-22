import CoreGraphics
import Testing

@testable import ChequeKit

struct ChequeDetectorTests {
    @Test(
        "Finds the corners of a cheque",
        arguments: [
            // Straight.
            ChequeCorners(
                topLeft: CGPoint(x: 300, y: 1000), topRight: CGPoint(x: 1700, y: 1000),
                bottomRight: CGPoint(x: 1700, y: 400), bottomLeft: CGPoint(x: 300, y: 400)),
            // Rotated by about 8°.
            ChequeCorners(
                topLeft: CGPoint(x: 330, y: 1100), topRight: CGPoint(x: 1716, y: 905),
                bottomRight: CGPoint(x: 1632, y: 311), bottomLeft: CGPoint(x: 246, y: 506)),
            // In perspective.
            ChequeCorners(
                topLeft: CGPoint(x: 380, y: 980), topRight: CGPoint(x: 1620, y: 1040),
                bottomRight: CGPoint(x: 1760, y: 350), bottomLeft: CGPoint(x: 240, y: 420)),
        ]
    )
    func findsCorners(of cheque: ChequeCorners) throws {
        // GIVEN
        let photo = SyntheticPhoto.make(cheque: cheque)

        // WHEN
        let corners = try #require(try ChequeDetector.corners(in: photo))

        // THEN
        #expect(corners.maximumDistance(to: cheque) < 20)
    }

    @Test("Takes a photo cropped to the cheque whole")
    func takesCroppedPhotoWhole() throws {
        // GIVEN
        let wholePhoto = ChequeCorners(
            topLeft: CGPoint(x: 0, y: 900), topRight: CGPoint(x: 2100, y: 900),
            bottomRight: CGPoint(x: 2100, y: 0), bottomLeft: .zero)
        let photo = SyntheticPhoto.make(cheque: wholePhoto, size: CGSize(width: 2100, height: 900))

        // WHEN
        let corners = try ChequeDetector.corners(in: photo)

        // THEN
        #expect(corners == wholePhoto)
    }

    @Test("Finds no cheque in an empty photo")
    func findsNoCheque() throws {
        // GIVEN
        let photo = SyntheticPhoto.make(cheque: nil)

        // WHEN
        let corners = try ChequeDetector.corners(in: photo)

        // THEN
        #expect(corners == nil)
    }
}

import CoreGraphics
import Testing

@testable import ChequeKit

struct ChequeReaderTests {
    @Test("Reads the CMC-7 line of a specimen photographed in perspective")
    func readsSpecimen() async throws {
        // GIVEN
        let photo = SyntheticSpecimen.photo(
            of: SyntheticSpecimen.make(), at: Self.perspective, size: CGSize(width: 3840, height: 2400))

        // WHEN
        let reading = try await ChequeReader().read(photo)

        // THEN
        #expect(reading.isVerified)
        #expect(reading.line == (try CMC7Line(parsing: Fixtures.specimenLine)))
    }

    @Test("Returns an unverified reading without correcting it")
    func returnsUnverifiedReading() async throws {
        // GIVEN
        let misprinted = Fixtures.specimenLine.replacing(position: 30, with: "0")
        let photo = SyntheticSpecimen.photo(
            of: SyntheticSpecimen.make(digits: misprinted), at: Self.perspective,
            size: CGSize(width: 3840, height: 2400))

        // WHEN
        let reading = try await ChequeReader().read(photo)

        // THEN
        #expect(reading.mismatchedGroups == [.third])
        #expect(reading.line == (try CMC7Line(parsing: misprinted)))
    }

    @Test("Finds no cheque in an empty photo")
    func findsNoCheque() async {
        // WHEN / THEN
        await #expect(throws: ChequeReader.ReadError.chequeNotFound) {
            try await ChequeReader().read(SyntheticPhoto.make(cheque: nil))
        }
    }

    @Test("Finds no line on a cheque without one")
    func findsNoLine() async {
        // GIVEN
        let photo = SyntheticPhoto.make(
            cheque: ChequeCorners(
                topLeft: CGPoint(x: 300, y: 1000), topRight: CGPoint(x: 1700, y: 1000),
                bottomRight: CGPoint(x: 1700, y: 400), bottomLeft: CGPoint(x: 300, y: 400)))

        // WHEN / THEN
        await #expect(throws: ChequeReader.ReadError.lineNotFound) {
            try await ChequeReader().read(photo)
        }
    }

    @Test("Accepts a verified reading that a neighbouring angle confirms")
    func acceptsConfirmedReading() throws {
        // GIVEN
        let verified = CMC7Reading(line: try CMC7Line(parsing: Fixtures.specimenLine))
        let readings = [0: verified, 1: verified]

        // WHEN
        let reading = ChequeReader.agreedReading { readings[$0] }

        // THEN
        #expect(reading == verified)
    }

    @Test("Ignores a verified reading that no neighbouring angle confirms")
    func ignoresUnconfirmedReading() throws {
        // GIVEN
        let lucky = CMC7Reading(line: try CMC7Line(parsing: "001123400180001245200001234566"))
        let verified = CMC7Reading(line: try CMC7Line(parsing: Fixtures.specimenLine))
        let readings = [0: lucky, 5: verified, -5: verified, 6: verified]

        // WHEN
        let reading = ChequeReader.agreedReading { readings[$0] }

        // THEN
        #expect(reading == verified)
    }

    @Test("Falls back to the first unverified reading")
    func fallsBackToUnverifiedReading() throws {
        // GIVEN
        let misprinted = Fixtures.specimenLine.replacing(position: 30, with: "0")
        let unverified = CMC7Reading(line: try CMC7Line(parsing: misprinted))
        let lucky = CMC7Reading(line: try CMC7Line(parsing: Fixtures.specimenLine))
        let readings = [2: unverified, 7: lucky]

        // WHEN
        let reading = ChequeReader.agreedReading { readings[$0] }

        // THEN
        #expect(reading == unverified)
    }

    private static let perspective = ChequeCorners(
        topLeft: CGPoint(x: 360, y: 1900), topRight: CGPoint(x: 3480, y: 1960),
        bottomRight: CGPoint(x: 3640, y: 520), bottomLeft: CGPoint(x: 200, y: 600))
}

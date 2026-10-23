import ChequeKit
import Testing

struct PublicAPITests {
    @Test("Reads a line as a host app does")
    func readsLineAsHostApp() async throws {
        // GIVEN
        let line = try CMC7Line(parsing: Fixtures.specimenLine)

        // WHEN
        let reading = await Task.detached { CMC7Reading(line: line) }.value

        // THEN
        #expect(reading.line == line)
        #expect(reading.isVerified)
        #expect(reading.mismatchedGroups.isEmpty)
        #expect(line.bankCode == "001")
        #expect(line.branch == "1234")
        #expect(line.clearingCode == "018")
        #expect(line.chequeNumber == "000123")
        #expect(line.chequeType == .ordinary)
        #expect(line.accountField == "0000123456")
    }

    @Test("Reports a format error to a host app")
    func reportsFormatErrorToHostApp() {
        // WHEN / THEN
        #expect(throws: CMC7Line.FormatError.invalidLength(CMC7Line.length + 1)) {
            try CMC7Line(parsing: Fixtures.specimenLine + "0")
        }
    }

    @Test("Reports a photo without a cheque to a host app")
    func reportsMissingChequeToHostApp() async {
        // GIVEN
        let photo = SyntheticPhoto.make(cheque: nil)

        // WHEN / THEN
        await #expect(throws: ChequeReader.ReadError.chequeNotFound) {
            try await ChequeReader().read(photo)
        }
    }
}

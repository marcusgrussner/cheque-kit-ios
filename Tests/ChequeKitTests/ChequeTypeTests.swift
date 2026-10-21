import Testing

@testable import ChequeKit

struct ChequeTypeTests {
    @Test(
        "Maps each cheque type code to its type",
        arguments: [
            (5, .ordinary),
            (6, .paymentOrder),
            (7, .travellers),
            (8, .administrative),
            (0, .unrecognized(0)),  // no type uses this code
            (9, .unrecognized(9)),  // no type uses this code
        ] as [(Int, ChequeType)]
    )
    func mapsChequeTypeCode(code: Int, expected: ChequeType) {
        // WHEN
        let type = ChequeType(code: code)

        // THEN
        #expect(type == expected)
    }
}

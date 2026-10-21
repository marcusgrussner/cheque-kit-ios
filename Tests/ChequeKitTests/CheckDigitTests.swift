import Testing

@testable import ChequeKit

struct CheckDigitTests {
    @Test(
        "Computes the check digit that guards a run of CMC-7 digits",
        arguments: [
            ([3, 4, 1, 0, 6, 7, 3], 2),  // Itaú: guards bank code and branch
            ([0, 3, 3, 0, 0, 1, 8, 8, 0, 5], 3),  // Itaú: guards group 2
            ([0, 1, 7, 2, 5, 7, 6, 6, 0, 9], 9),  // Itaú: guards the account field
            ([0, 0, 0, 0, 0, 0, 0], 0),  // a sum that is a multiple of 10 gives 0, never 10
            ([9], 1),  // 9 × 2 = 18 → 1 + 8
            ([5], 9),  // 5 × 2 = 10 → 1 + 0
        ]
    )
    func computesCheckDigit(digits: [Int], expected: Int) {
        // WHEN
        let result = CheckDigit.compute(for: digits)

        // THEN
        #expect(result == expected)
    }
}

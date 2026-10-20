import Testing

@testable import ChequeKit

@Test(
    "Computes the check digit that guards a run of CMC-7 digits",
    arguments: [
        ([0, 0, 1, 1, 2, 3, 4], 2),  // Itaú: guards bank code and branch
        ([0, 1, 8, 0, 0, 0, 1, 2, 3, 5], 1),  // Itaú: guards group 2
        ([0, 0, 0, 0, 1, 2, 3, 4, 5, 6], 6),  // Itaú: guards the account field
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

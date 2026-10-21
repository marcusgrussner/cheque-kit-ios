/// The mod 10 algorithm behind the three check digits of a CMC-7 line, which is the Luhn
/// check digit.
///
/// Which digits each check digit guards, and where it is printed, is described in
/// ``CMC7Line/Group``.
enum CheckDigit {
    /// Computes the check digit that guards the given digits.
    ///
    /// Weights 2, 1, 2, 1… are applied from the rightmost digit; a product
    /// above 9 contributes the sum of its digits. The check digit is
    /// `(10 - sum % 10) % 10`.
    ///
    /// ```swift
    /// CheckDigit.compute(for: [3, 4, 1, 0, 6, 7, 3])  // 2
    /// ```
    ///
    /// - Parameter digits: The guarded digits, most significant first, each in `0...9`.
    /// - Returns: The check digit, in `0...9`.
    static func compute(for digits: [Int]) -> Int {
        var sum = 0
        for (offset, digit) in digits.reversed().enumerated() {
            let weight = offset.isMultiple(of: 2) ? 2 : 1
            let product = digit * weight
            sum += product / 10 + product % 10
        }
        return (10 - sum % 10) % 10
    }
}

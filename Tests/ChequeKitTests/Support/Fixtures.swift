/// Test data shared by the ChequeKit test suites.
enum Fixtures {
    /// A synthetic CMC-7 line whose three check digits all match.
    ///
    /// It belongs to no real cheque: bank code `001`, branch `1234`, clearing code `018`,
    /// cheque number `000123`, cheque type 5 and account field `0000123456`, with check digits
    /// recomputed for those values. Groups: `00112341` · `0180001235` · `200001234566`.
    static let specimenLine = "001123410180001235200001234566"
}

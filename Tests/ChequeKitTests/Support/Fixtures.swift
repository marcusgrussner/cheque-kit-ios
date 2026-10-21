/// Test data shared by the ChequeKit test suites.
enum Fixtures {
    /// A CMC-7 line from an Itaú cheque whose three check digits all match.
    ///
    /// Groups: `34106733` · `0330018805` · `201725766099`. Published as an example on the
    /// ACBr forum: https://www.projetoacbr.com.br/forum/topic/38733-problema-ao-desmembrar-c1-utilizando-o-cmc7-do-cheque/
    static let itauLine = "341067330330018805201725766099"
}

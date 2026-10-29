# Security policy

## Supported versions

ChequeKit is in early development. Only the latest 0.x release receives security fixes.

| Version | Supported |
|---|---|
| Latest 0.x | ✅ |
| Older | ❌ |

## Reporting a vulnerability

Report it privately through GitHub: open the **Security** tab of this repository and choose **Report a vulnerability**. Do not open a public issue.

Describe the problem, the affected version and the steps to reproduce it. **Never attach a photo or the CMC-7 line of a real cheque**: cheques carry personal data protected by Brazil's LGPD. Use a synthetic specimen, or a photo with every field redacted.

ChequeKit has a single maintainer, so responses are best effort. You should hear back within 7 days; a fix and an advisory follow once the problem is confirmed.

## Scope

In scope:

- **A wrong reading reported as verified**: a CMC-7 line whose digits differ from the cheque's, yet `isVerified` is `true`.
- **Data leaving memory**: ChequeKit writing an image or reading to disk, logging it, or sending it over the network.
- **Crashes or hangs on crafted images**, which a host app could be made to process.

Out of scope, as the [README](README.md#what-it-does-not-do) states:

- Fraud detection: tampered cheques, screen recaptures, forged signatures.
- Matching check digits taken as proof that a cheque is authentic.
- How a host app stores or transmits the readings ChequeKit returns.

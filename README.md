# ChequeKit

On-device capture of Brazilian bank cheques and validated reading of their CMC-7 line, for iOS.

> [!WARNING]
> **Work in progress.** ChequeKit is under active development: nothing is released yet and the API will change. Do not use it in production.

## What it does

- **Reads a cheque's CMC-7 line from a still photo**, finding the cheque and correcting its perspective before decoding.
- **Checks all three check digits**, returning the bank code, branch, clearing code, cheque number, cheque type and account field. Unverified readings are returned without correcting any digit.
- **Runs on-device**, with a minimal iOS example app.

Camera capture, image-quality checks, theming and the ready-made `ChequeKitUI` flow are planned for later versions. `ChequeKitUI` is currently a placeholder.

## Reading a photo

```swift
import ChequeKit

let reading = try await ChequeReader().read(photo) // photo is an upright CGImage
if reading.isVerified {
    // All three check digits match.
}
```

Reading currently needs about 300 dpi across the cheque. Validation so far covers three cheques from one bank and synthetic specimens; robustness across banks and capture conditions remains to be established. Matching check digits do not prove that a cheque is authentic.

## What it does not do

- **No fraud detection** of any kind: tampering, screen recaptures and forged signatures are out of scope.
- **No proof that the back belongs to the same cheque** as the front.
- **No reading of endorsements, signatures, crossings or handwritten fields** in 1.0.
- **No deposit**: depositing a cheque is the host app's business; ChequeKit captures and reads.
- **No claim of Compe compliance.** A Compe-oriented export is planned but is not implemented.

## Why cheques in 2026?

Brazil still processed **112.5 million cheques worth R$ 472.7 billion in 2025**. That is 18.2% fewer than in 2024, yet still a flow that banks and fintechs must handle ([Febraban](https://portal.febraban.org.br/noticia/4440/en-us)). Accepting a cheque in an app starts with two good images and a correct CMC-7 reading, and that is the part ChequeKit owns.

## Requirements

| | Minimum |
|---|---|
| iOS / iPadOS deployment target | 15.0 |
| Xcode | 26 |
| Swift | 6.2 |

CI runs automated tests on macOS with Xcode 26.0.1 and on an iOS 26 simulator with Xcode 26.5, builds both libraries for an iOS 15.0 deployment target with Xcode 26.2, and builds the example app with Xcode 26.2. Runtime behaviour on a physical iOS 15 device has not yet been validated. See [ADR-0002](docs/adr/0002-ios-15-floor-tests-on-ios-17.md) for the intended validation policy.

## Privacy

- **Everything runs on-device.** ChequeKit makes no network calls and has no third-party runtime dependencies.
- **Images stay in memory.** ChequeKit never writes them to disk; what happens to a scan result is up to the host app.
- **Cheques carry personal data** (names, CPF/CNPJ, account data, signatures) protected by Brazil's LGPD. Handle scan results accordingly.

## Example app

`Examples/ChequeKitDemo` is a small iOS app that reads the CMC-7 line of a cheque photo with ChequeKit: choose a photo, and it shows the line's fields and whether each check digit matches. It uses the package in this repository, so it always runs the code of the branch you are on.

1. Open `Examples/ChequeKitDemo/ChequeKitDemo.xcodeproj` in Xcode and run the `ChequeKitDemo` scheme on a simulator. The project opens with Xcode 26 or later.
2. Add a photo of a cheque to the simulator's library: `xcrun simctl addmedia booted cheque.heic`.
3. Tap **Choose a photo of a cheque**.

The app keeps nothing: it reads the photo in memory, and the photo picker hands it only the photo you choose, without access to the rest of the library.

## Roadmap

- **0.1**: core reads and validates the CMC-7 line from a still image, with a minimal example app.
- **0.5**: camera capture flow with auto-capture and theming.
- **1.0**: stable API, DocC documentation and a complete example app.

## Documentation

- [Glossary](GLOSSARY.md): the domain vocabulary used across code and docs.
- [Architecture decision records](docs/adr/): why ChequeKit is built the way it is.

## License

ChequeKit is released under the [Apache License 2.0](LICENSE). See [NOTICE](NOTICE) for attribution.

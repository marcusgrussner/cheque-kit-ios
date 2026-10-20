# ChequeKit

On-device capture of Brazilian bank cheques and validated reading of their CMC-7 line, for iOS.

> [!WARNING]
> **Work in progress.** ChequeKit is under active development: nothing is released yet and the API will change. Do not use it in production.

## What it does

- **Captures both sides of a cheque**, front and back, cropped and perspective-corrected, with quality checks for blur, glare, exposure and framing.
- **Reads the CMC-7 line** printed along the bottom of the front and validates its three check digits, returning the bank code, branch, clearing code, cheque number, cheque type and account field.
- **Fits your app, your way**: `ChequeKit` is a headless core you drive with your own UI; `ChequeKitUI` is a ready-made capture flow that adopts your institution's visual identity.

## What it does not do

- **No fraud detection** of any kind: tampering, screen recaptures and forged signatures are out of scope.
- **No proof that the back belongs to the same cheque** as the front.
- **No reading of endorsements, signatures, crossings or handwritten fields** in 1.0.
- **No deposit**: depositing a cheque is the host app's business; ChequeKit captures and reads.
- **No claim of Compe compliance**: the optional greyscale export follows public references and is not certified.

## Why cheques in 2026?

Brazil still processed **112.5 million cheques worth R$ 472.7 billion in 2025**. That is 18.2% fewer than in 2024, yet still a flow that banks and fintechs must handle ([Febraban](https://portal.febraban.org.br/noticia/4440/en-us)). Accepting a cheque in an app starts with two good images and a correct CMC-7 reading, and that is the part ChequeKit owns.

## Requirements

| | Minimum |
|---|---|
| iOS / iPadOS deployment target | 15.0 |
| Xcode | 26 |
| Swift | 6.2 |

Automated tests run on iOS 17 and later; iOS 15 is verified manually before each release ([ADR-0002](docs/adr/0002-ios-15-floor-tests-on-ios-17.md)).

## Privacy

- **Everything runs on-device.** ChequeKit makes no network calls and has no third-party runtime dependencies.
- **Images stay in memory.** ChequeKit never writes them to disk; what happens to a scan result is up to the host app.
- **Cheques carry personal data** (names, CPF/CNPJ, account data, signatures) protected by Brazil's LGPD. Handle scan results accordingly.

## Roadmap

- **0.1**: core reads and validates the CMC-7 line from a still image.
- **0.5**: camera capture flow with auto-capture and theming.
- **1.0**: stable API, DocC documentation and an example app.

## Documentation

- [Glossary](GLOSSARY.md): the domain vocabulary used across code and docs.
- [Architecture decision records](docs/adr/): why ChequeKit is built the way it is.

## License

ChequeKit is released under the [Apache License 2.0](LICENSE). See [NOTICE](NOTICE) for attribution.

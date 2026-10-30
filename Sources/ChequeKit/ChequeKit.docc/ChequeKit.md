# ``ChequeKit``

Read and validate the CMC-7 line of a Brazilian bank cheque from a photo, on-device.

## Overview

ChequeKit finds the cheque in a photo of its front, corrects its perspective and decodes the CMC-7 line printed along its bottom edge. It then checks the line's three check digits and returns the bank code, branch, clearing code, cheque number, cheque type and account field.

```swift
let reading = try await ChequeReader().read(photo)
if reading.isVerified {
    // All three check digits match.
}
```

A reading whose check digits do not match is still returned, as read: ChequeKit never corrects a digit, and your app decides what to do with it. Matching check digits do not prove that a cheque is authentic.

Everything runs on-device. ChequeKit makes no network calls and never writes an image to disk. Cheques carry personal data protected by Brazil's LGPD, so handle the photos and readings your app keeps accordingly.

> Important: ChequeKit is in early development and its API will change before 1.0. Reading currently needs about 300 dpi across the cheque, and has been validated on cheques from one bank only.

## Topics

### Essentials

- <doc:ReadingAChequePhoto>
- <doc:VerifiedAndUnverifiedReadings>

### Reading a cheque

- ``ChequeReader``
- ``ChequeReader/ReadError``

### Readings and check digits

- ``CMC7Reading``
- ``CMC7Line``
- ``CMC7Line/Group``
- ``CMC7Line/FormatError``

### Cheque fields

- ``ChequeType``

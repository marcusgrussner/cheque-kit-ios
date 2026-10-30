# Reading a cheque photo

Turn a photo of the front of a cheque into a validated CMC-7 reading.

## Overview

``ChequeReader`` takes a photo of the front of a cheque, finds the cheque in it, straightens it and decodes its CMC-7 line. The photo can show the cheque on a table or be cropped to it.

### Get an upright image

``ChequeReader/read(_:)`` takes a `CGImage` whose pixels are the right way up. Cameras often store a photo's pixels sideways, with an orientation flag that `UIImage` honours when it draws but `UIImage.cgImage` ignores. Draw the image once to get its pixels turned the way the photo is shown:

```swift
import UIKit

extension UIImage {
    func uprightCGImage() -> CGImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in draw(at: .zero) }.cgImage
    }
}
```

Reading needs about 300 dpi across the cheque, which is about 2,100 pixels across a cheque 175 mm wide. A full-resolution photo from an iPhone camera, with the cheque filling most of the frame, is enough; a 1080p video frame is not.

### Read the line

Call ``ChequeReader/read(_:)`` with the photo. It runs off the caller's actor, so calling it from the main actor does not block your interface:

```swift
import ChequeKit

func read(_ image: UIImage) async {
    guard let photo = image.uprightCGImage() else { return }
    do {
        let reading = try await ChequeReader().read(photo)
        show(reading)
    } catch ChequeReader.ReadError.chequeNotFound {
        // Ask for a photo that shows the whole cheque.
    } catch ChequeReader.ReadError.lineNotFound {
        // Ask for a sharper, closer or better lit photo.
    } catch {
        // Vision or Core Image could not process the photo.
    }
}
```

The reader throws ``ChequeReader/ReadError/chequeNotFound`` when the photo shows no cheque, and ``ChequeReader/ReadError/lineNotFound`` when it finds a cheque but no well-formed CMC-7 line on it. Both usually mean the photo should be taken again.

### Use the reading

A ``CMC7Reading`` holds the ``CMC7Line`` as read and the outcome of its three check digits:

```swift
func show(_ reading: CMC7Reading) {
    let line = reading.line
    print(line.bankCode, line.branch, line.chequeNumber)
    if !reading.isVerified {
        // Some digits were misread: see VerifiedAndUnverifiedReadings.
    }
}
```

The code fields are strings, so they keep their leading zeros. Before relying on any of them, check ``CMC7Reading/isVerified``, as <doc:VerifiedAndUnverifiedReadings> explains.

### Keep the data private

ChequeKit keeps the photo in memory only and returns the reading to your app. A cheque shows its drawer's name, CPF or CNPJ, account and signature, all personal data under Brazil's LGPD. Keep only what your app needs, and do not write photos or readings to logs.

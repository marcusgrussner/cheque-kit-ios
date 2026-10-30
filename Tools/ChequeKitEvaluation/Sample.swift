import ChequeKit
import CoreGraphics
import Foundation
import ImageIO

/// A photo of the front of a real cheque, with the CMC-7 line printed on it.
struct Sample {
    let id: String
    let photo: URL
    let groundTruth: CMC7Line

    enum LoadError: Error, CustomStringConvertible {
        case missingManifest(URL)
        case unreadableImage(URL)

        var description: String {
            switch self {
            case .missingManifest(let url): "No samples.csv in \(url.path)"
            case .unreadableImage(let url): "Cannot read the image \(url.lastPathComponent)"
            }
        }
    }

    /// Loads the samples listed in `samples.csv`, skipping and reporting the rows that cannot be evaluated.
    ///
    /// The manifest has a header row and then one row per cheque: its id and its CMC-7 line as 30 digits. The photo of
    /// the front is the file named `<id>-front` with any extension. A row is skipped when its line does not pass its
    /// check digits, since a reading could then never match it, or when it has no photo of the front.
    static func load(from folder: URL) throws -> (samples: [Sample], skipped: [String]) {
        let manifest = folder.appendingPathComponent("samples.csv")
        guard let csv = try? String(contentsOf: manifest, encoding: .utf8) else {
            throw LoadError.missingManifest(folder)
        }
        let files = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []

        var samples: [Sample] = []
        var skipped: [String] = []
        for row in csv.split(whereSeparator: \.isNewline).dropFirst() {
            let fields = row.split(separator: ",", omittingEmptySubsequences: false)
            let id = String(fields[0])
            guard fields.count > 1, let line = try? CMC7Line(parsing: String(fields[1])),
                CMC7Reading(line: line).isVerified
            else {
                skipped.append("\(id): its line is not a verified CMC-7 line")
                continue
            }
            guard let photo = files.first(where: { $0.deletingPathExtension().lastPathComponent == "\(id)-front" })
            else {
                skipped.append("\(id): no photo named \(id)-front")
                continue
            }
            samples.append(Sample(id: id, photo: photo, groundTruth: line))
        }
        return (samples, skipped)
    }

    /// Decodes the photo, upright as its orientation tag says.
    func image() throws -> CGImage {
        let options =
            [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: 100_000,
            ] as CFDictionary
        guard let source = CGImageSourceCreateWithURL(photo as CFURL, nil),
            let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options)
        else { throw LoadError.unreadableImage(photo) }
        return image
    }
}

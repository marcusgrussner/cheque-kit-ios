import ChequeKit
import CoreGraphics
import Foundation
import ImageIO

let samplesFolder =
    CommandLine.arguments.dropFirst().first.map { URL(filePath: $0) }
    ?? FileManager.default.homeDirectoryForCurrentUser.appending(path: "ChequeKit-PrivateSamples")
let csv = try String(contentsOf: samplesFolder.appending(path: "samples.csv"), encoding: .utf8)

for row in csv.split(whereSeparator: \.isNewline).dropFirst() {
    let fields = row.split(separator: ",", omittingEmptySubsequences: false)
    let id = fields[0]
    guard let groundTruth = try? CMC7Line(parsing: String(fields[1])), CMC7Reading(line: groundTruth).isVerified else {
        print(id, "ground truth is not a verified line, skipped")
        continue
    }
    for side in ["front", "back"] {
        let photo = try loadImage(at: samplesFolder.appending(path: "\(id)-\(side).heic"))
        do {
            let reading = try await ChequeReader().read(photo)
            let verdict = reading.isVerified ? "verified" : "unverified in \(reading.mismatchedGroups)"
            let match = reading.line == groundTruth ? "matches the ground truth" : "differs from the ground truth"
            print(id, side, verdict + ",", match)
        } catch {
            print(id, side, "error: \(error)")
        }
    }
}

// MARK: - Images

enum SpikeError: Error {
    case unreadableImage(URL)
}

func loadImage(at url: URL) throws -> CGImage {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
        let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else { throw SpikeError.unreadableImage(url) }
    return image
}

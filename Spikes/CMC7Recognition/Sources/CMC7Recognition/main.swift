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
    let groundTruth = String(fields[1])
    guard  let line = try? CMC7Line(parsing: groundTruth), CMC7Reading(line: line).isVerified else {
        print(id, "ground truth is not a verified line, skipped")
        continue
    }
    let image = GreyImage(try loadImage(at: samplesFolder.appending(path: "\(id)-front.heic")))
    let band = findBandRows(in: image)
    let bars = findBars(in: image, rows: band)
    let gaps = zip(bars, bars.dropFirst()).map { $1.lowerBound - $0.upperBound }
    print(id, "band rows \(band), \(bars.count) bars")
    print("  bar widths:", histogram(bars.map(\.count)))
    print("  gaps:", histogram(gaps))
}

// MARK: - Images

enum SpikeError: Error {
    case unreadableImage(URL)
}

func loadImage(at url: URL) throws -> CGImage {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil), let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
        throw SpikeError.unreadableImage(url)
    }
    return image
}

// MARK: - Report

func histogram(_ values: [Int]) -> String {
    Dictionary(grouping: values, by: \.self)
        .sorted { $0.key < $1.key }
        .map { "\($0.key)×\($0.value.count)" }
        .joined(separator: " ")
}

func report(recognized text: String, groundTruth: String) -> String {
    let shape = String(text.map { $0.isASCII && $0.isNumber ? "#" : $0 })
    let digits = text.filter { $0.isASCII && $0.isNumber }
    var verdict = "\(digits.count) digits"
    if let line = try? CMC7Line(parsing: digits) {
        let reading = CMC7Reading(line: line)
        verdict += reading.isVerified ? ", verified" : ", unverified \(reading.mismatchedGroups)"
        let wrong = zip(digits, groundTruth).enumerated().filter { $0.element.0 != $0.element.1 }.map { $0.offset + 1 }
        verdict += wrong.isEmpty ? ", matches ground truth" : ", differs from ground truth at \(wrong)"
    }

    return "shape \"\(shape)\" · \(verdict)"
}
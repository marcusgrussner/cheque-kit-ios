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
    let photo = try loadImage(at: samplesFolder.appending(path: "\(id)-front.heic"))
    let widthInInches = Double(fields[2])! / 25.4
    print(id, "photo: \(Int(Double(photo.width) / widthInInches)) dpi")
    for dpi in [400, 300, 250, 200] {
        let image = GreyImage(try scaled(photo, toWidth: Int(Double(dpi) * widthInInches)))
        let bars = findBars(in: image, rows: findBandRows(in: image))
        print("  \(dpi) dpi:", report(recognized: decode(bars: bars), groundTruth: groundTruth))
    }
}

// MARK: - Images

enum SpikeError: Error {
    case unreadableImage(URL)
    case unscalableImage
}

func loadImage(at url: URL) throws -> CGImage {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil), let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
        throw SpikeError.unreadableImage(url)
    }
    return image
}

func scaled(_ image: CGImage, toWidth width: Int) throws -> CGImage {
    let height = image.height * width / image.width
    guard
        let context = CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue)
    else { throw SpikeError.unscalableImage }
    context.interpolationQuality = .high
    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    guard let scaled = context.makeImage() else { throw SpikeError.unscalableImage }
    return scaled
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
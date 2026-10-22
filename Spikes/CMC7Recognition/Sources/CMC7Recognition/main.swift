import ChequeKit
import CoreGraphics
import Foundation
import ImageIO
import Vision

let samplesFolder =
    CommandLine.arguments.dropFirst().first.map { URL(filePath: $0) }
    ?? FileManager.default.homeDirectoryForCurrentUser.appending(path: "ChequeKit-PrivateSamples")
let csv = try String(contentsOf: samplesFolder.appending(path: "samples.csv"), encoding: .utf8)
let configurations: [(revision: Int, level: VNRequestTextRecognitionLevel)] = [
    (VNRecognizeTextRequestRevision2, .accurate),
    (VNRecognizeTextRequestRevision2, .fast),
    (VNRecognizeTextRequestRevision3, .accurate),
    (VNRecognizeTextRequestRevision3, .fast),
]

for row in csv.split(whereSeparator: \.isNewline).dropFirst() {
    let fields = row.split(separator: ",", omittingEmptySubsequences: false)
    let id = fields[0]
    let groundTruth = String(fields[1])
    guard  let line = try? CMC7Line(parsing: groundTruth), CMC7Reading(line: line).isVerified else {
        print(id, "ground truth is not a verified line, skipped")
        continue
    }
    let image = try loadImage(at: samplesFolder.appending(path: "\(id)-front.heic"))
    for configuration in configurations {
        let text = try recognizeText(in: image, revision: configuration.revision, level: configuration.level)
        let level = configuration.level == .fast ? "fast" : "accurate"
        print(id, "revision \(configuration.revision) \(level):", report(recognized: text, groundTruth: groundTruth))
    }
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

// MARK: - Vision

func recognizeText(in image: CGImage, revision: Int, level: VNRequestTextRecognitionLevel) throws -> String {
    let request = VNRecognizeTextRequest()
    request.revision = revision
    request.recognitionLevel = level
    request.usesLanguageCorrection = false
    request.regionOfInterest = CGRect(x: 0, y: 0, width: 1, height: 0.15)
    try VNImageRequestHandler(cgImage: image).perform([request])
    let observations = (request.results ?? []).sorted { $0.boundingBox.minX < $1.boundingBox.minX }

    return observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")
}

// MARK: - Report

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
import ChequeKit
import Foundation

let samplesFolder =
    CommandLine.arguments.dropFirst().first.map { URL(filePath: $0) }
    ?? FileManager.default.homeDirectoryForCurrentUser.appending(path: "ChequeKit-PrivateSamples")
let csv = try String(contentsOf: samplesFolder.appending(path: "samples.csv"), encoding: .utf8)

for row in csv.split(whereSeparator: \.isNewline).dropFirst() {
    let fields = row.split(separator: ",", omittingEmptySubsequences: false)
    let id = fields[0]
    do {
        let reading = CMC7Reading(line: try CMC7Line(parsing: String(fields[1])))
        print(id, reading.isVerified ? "ground truth verified" : "ground truth mismatched: \(reading.mismatchedGroups)")
    } catch {
        print(id, "ground truth malformed: \(error)")
    }
}
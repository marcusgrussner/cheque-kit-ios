// Reads every photo of a folder of real cheques with ChequeKit, in its original form and in degraded variants, and
// reports how often the reading is correct, how often a wrong reading passes its check digits, and how long it takes.
//
//     swift run -c release ChequeKitEvaluation [samples folder] [--original-only]
//
// The samples folder defaults to ~/ChequeKit-PrivateSamples and holds a samples.csv manifest and the photos it names.
// Real cheques never enter the repository, and no report prints the digits of a line. A per-read CSV report is written
// to evaluation.csv in the samples folder. The tool exits with status 1 when any reading is a false accept.

import ChequeKit
import CoreGraphics
import Foundation

let arguments = CommandLine.arguments.dropFirst()
let folder =
    arguments.first { !$0.hasPrefix("--") }.map { URL(fileURLWithPath: ($0 as NSString).expandingTildeInPath) }
    ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("ChequeKit-PrivateSamples")
let variants = arguments.contains("--original-only") ? [Variant.original] : Variant.all

let (samples, skipped) = try Sample.load(from: folder)
for reason in skipped {
    print("Skipped \(reason)")
}
print("Reading \(samples.count) samples in \(variants.count) variants\n")

struct Read {
    let sample: Sample
    let variant: Variant
    let outcome: Outcome
    let milliseconds: Int
}

var reads: [Read] = []
var unreadable: [String] = []
for sample in samples {
    // A photo that cannot be decoded is a problem with the samples, not with the reader: skip it and keep the rest of
    // the evaluation, rather than count it against the reader or lose the reads made so far.
    let photo: CGImage
    do {
        photo = try sample.image()
    } catch {
        print("Skipped \(sample.id): \(error)")
        unreadable.append(sample.id)
        continue
    }
    for variant in variants {
        let image = variant.apply(to: photo)
        let start = DispatchTime.now()
        let outcome: Outcome
        do {
            outcome = Outcome(reading: try await ChequeReader().read(image), groundTruth: sample.groundTruth)
        } catch {
            outcome = Outcome(error: error)
        }
        let elapsed = DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds
        let read = Read(sample: sample, variant: variant, outcome: outcome, milliseconds: Int(elapsed / 1_000_000))
        reads.append(read)
        print("\(sample.id)  \(variant)  \(outcome.label)  \(read.milliseconds) ms")
    }
}

// MARK: - Summary

print("\n" + Report.summary(of: reads.map { ($0.variant.description, $0.outcome, $0.milliseconds) }))

let csv =
    "id,variant,outcome,milliseconds\n"
    + reads.map { "\($0.sample.id),\($0.variant),\($0.outcome.label),\($0.milliseconds)" }
    .joined(separator: "\n") + "\n"
let report = folder.appendingPathComponent("evaluation.csv")
try csv.write(to: report, atomically: true, encoding: .utf8)
print("\nPer-read report: \(report.path)")

if !unreadable.isEmpty {
    print("\nSkipped \(unreadable.count) samples whose photo could not be read: \(unreadable.joined(separator: ", "))")
}

let falseAccepts = reads.count { if case .falseAccept = $0.outcome { true } else { false } }
if falseAccepts > 0 {
    print("\n\(falseAccepts) wrong readings passed their check digits.")
    exit(1)
}

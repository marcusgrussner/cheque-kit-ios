import ChequeKit
import SwiftUI

/// The fields of a CMC-7 reading and the outcome of each check digit.
struct ReadingSection: View {
    let reading: CMC7Reading

    var body: some View {
        Section(reading.isVerified ? "Verified reading" : "Unverified reading") {
            row("Bank code", reading.line.bankCode)
            row("Branch", reading.line.branch)
            row("Clearing code", reading.line.clearingCode)
            row("Cheque number", reading.line.chequeNumber)
            row("Cheque type", "\(reading.line.chequeType)")
            row("Account field", reading.line.accountField)
        }
        Section("Check digits") {
            row("Group 1", status(of: .first))
            row("Group 2", status(of: .second))
            row("Group 3", status(of: .third))
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .font(.body.monospacedDigit())
                .foregroundColor(.secondary)
        }
    }

    private func status(of group: CMC7Line.Group) -> String {
        reading.mismatchedGroups.contains(group) ? "does not match" : "matches"
    }
}

import ChequeKit
import SwiftUI

struct ContentView: View {
    @State private var isPicking = false
    @State private var isReading = false
    @State private var reading: CMC7Reading?
    @State private var failure: String?

    var body: some View {
        NavigationView {
            List {
                Section {
                    Button("Choose a photo of a cheque") { isPicking = true }
                        .disabled(isReading)
                    if isReading {
                        ProgressView("Reading…")
                    }
                }
                if let reading {
                    ReadingSection(reading: reading)
                }
                if let failure {
                    Section {
                        Text(failure).foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("ChequeKit")
        }
        .sheet(isPresented: $isPicking) {
            PhotoPicker(onSelect: startReading, onPick: read)
        }
    }

    /// Marks the app busy from the moment a photo is chosen, so that no second photo can be chosen while the first
    /// one loads and is read.
    private func startReading() {
        reading = nil
        failure = nil
        isReading = true
    }

    private func read(_ image: UIImage?) {
        guard let photo = image?.uprightCGImage() else {
            failure = "The photo could not be loaded."
            isReading = false
            return
        }
        Task {
            defer { isReading = false }
            do {
                reading = try await ChequeReader().read(photo)
            } catch ChequeReader.ReadError.chequeNotFound {
                failure = "No cheque found in the photo."
            } catch ChequeReader.ReadError.lineNotFound {
                failure = "No CMC-7 line could be read on the cheque."
            } catch {
                failure = error.localizedDescription
            }
        }
    }
}

#Preview {
    ContentView()
}

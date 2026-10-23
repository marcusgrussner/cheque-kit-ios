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
                if let failure {
                    Section {
                        Text(failure).foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("ChequeKit")
        }
        .sheet(isPresented: $isPicking) {
            PhotoPicker { image in read(image) }
        }
    }

    private func read(_ image: UIImage) {
        guard let photo = image.uprightCGImage() else { return }
        reading = nil
        failure = nil
        isReading = true
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

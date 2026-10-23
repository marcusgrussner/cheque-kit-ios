import SwiftUI

struct ContentView: View {
    @State private var isPicking = false
    @State private var photo: CGImage?

    var body: some View {
        NavigationView {
            List {
                Button("Choose a photo of a cheque") { isPicking = true }
                if let photo {
                    Text("\(photo.width) x \(photo.height) px")
                }
            }
            .navigationTitle("ChequeKit")
        }
        .sheet(isPresented: $isPicking) {
            PhotoPicker { image in photo = image.uprightCGImage() }
        }
    }
}

#Preview {
    ContentView()
}

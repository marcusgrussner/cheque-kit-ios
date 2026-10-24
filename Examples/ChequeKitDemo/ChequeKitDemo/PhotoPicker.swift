import PhotosUI
import SwiftUI

/// Picks one photo from the library, for iOS 15, where SwiftUI has no photo picker of its own.
///
/// `onSelect` runs as soon as a photo is chosen, before it loads, which can take a while for a photo in iCloud;
/// `onPick` runs once it has loaded, with `nil` when it cannot be loaded.
struct PhotoPicker: UIViewControllerRepresentable {
    let onSelect: @MainActor () -> Void
    let onPick: @MainActor (UIImage?) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ picker: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect, onPick: onPick)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onSelect: @MainActor () -> Void
        let onPick: @MainActor (UIImage?) -> Void

        init(onSelect: @escaping @MainActor () -> Void, onPick: @escaping @MainActor (UIImage?) -> Void) {
            self.onSelect = onSelect
            self.onPick = onPick
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }
            onSelect()
            guard provider.canLoadObject(ofClass: UIImage.self) else {
                onPick(nil)
                return
            }
            let onPick = onPick
            provider.loadObject(ofClass: UIImage.self) { object, _ in
                let image = object as? UIImage
                Task { @MainActor in onPick(image) }
            }
        }
    }
}

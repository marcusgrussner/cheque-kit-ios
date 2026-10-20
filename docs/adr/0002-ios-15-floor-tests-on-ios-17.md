# Deploy to iOS 15, run automated tests on iOS 17 and later

ChequeKit's minimum deployment target is iOS 15.0, so institutions whose apps still support older devices can adopt it. Under Xcode 27, however, both XCTest and Swift Testing require iOS 17, and the iOS 15 simulator does not run on macOS 26 hosts, so automated tests can only run on iOS 17 and later. We accept that gap instead of raising the floor: CI compiles the package for iOS 15.0, automated tests run on iOS 17+, and iOS 15 behaviour is verified manually on a physical device before each release.

## Consequences

- The iOS 15 code path is the baseline, not a fallback. Newer APIs (Observation, the Swift-native Vision API, `DataScannerViewController`, `NavigationStack`) are used only behind `#available`, and only where they bring a measured benefit.
- The floor follows Xcode: it moves when a new Xcode drops iOS 15 as a deployment target, and raising it is treated as a breaking change.

# Leafy — iOS Plant Identification App

<!-- Badges -->
[![Platform - iOS](https://img.shields.io/badge/platform-iOS-000.svg?logo=apple)](https://developer.apple.com/ios/)
[![Swift - 5.x](https://img.shields.io/badge/Swift-5.x-F05138?logo=swift&logoColor=white)](https://swift.org/)
[![UI - SwiftUI](https://img.shields.io/badge/UI-SwiftUI-0D96F6?logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![Core ML](https://img.shields.io/badge/ML-Core%20ML-0B84FE)](https://developer.apple.com/machine-learning/)
[![Xcode](https://img.shields.io/badge/Xcode-14%2B-1575F9?logo=xcode&logoColor=white)](https://developer.apple.com/xcode/)
[![License](https://img.shields.io/badge/license-Custom-lightgrey)](#license)

<p align="center">
  <img src="docs/images/icon.png" alt="Leafy App Icon" width="120" />
</p>

Leafy is a SwiftUI iOS app that helps you identify plants using on-device machine learning and organize them in a simple garden list. It uses a Core ML image classification model (MobileNetV2) to predict the plant class from a photo you select or capture.

## Features

- **On-device plant identification** using Core ML (`MobileNetV2.mlmodel`).
- **Photo picker** to choose images from your library.
- **SwiftUI interface** with views for garden list and plant details.
- **Local persistence scaffold** provided for saving items (see `Persistence.swift`).
- **Unit/UI tests** templates in `LeafyTests` and `LeafyUITests`.

## Requirements

- Xcode 14+ (recommended)
- iOS 15+ deployment target (project default)
- macOS with Xcode toolchain

## Project Structure

- `Leafy/LeafyApp.swift` — App entry point (SwiftUI `@main`).
- `Leafy/Services/ImageClassifier.swift` — Wraps Core ML model inference.
- `Leafy/Model/MobileNetV2.mlmodel` — Image classification model used by the app.
- `Leafy/View/GardenView.swift` — Main list of identified plants.
- `Leafy/View/PlantDetailView.swift` — Details for a selected plant.
- `Leafy/View/ImagePicker.swift` — UIKit wrapper to pick an image from the photo library.
- `Leafy/View/PlantRowView.swift` — Row UI for each plant.
- `Leafy/Persistence.swift` — Persistence helpers (Core Data scaffold).
- `Leafy/Info.plist` and `Leafy/Leafy.entitlements` — App configuration.
- `Leafy/Leafy.xcdatamodeld/` — Core Data model container.
- `LeafyTests/` and `LeafyUITests/` — Unit and UI test targets.

## Getting Started

1. Open the project:
   - Double-click `Leafy/Leafy.xcodeproj` in Xcode.
2. Resolve signing:
   - In Xcode, select the `Leafy` target → Signing & Capabilities → choose your Team.
3. Build & Run:
   - Select an iOS Simulator (e.g., iPhone 15) or a physical device.
   - Press Run (⌘R).
4. Use the app:
   - Tap to pick a photo.
   - The classifier predicts the top label; you can view details and keep a simple list of identified plants.

## How Image Classification Works

`ImageClassifier.swift` loads the bundled Core ML model and runs prediction on a resized image buffer. The app reads the top classification label and displays it in the UI. You can swap in your own model by replacing `MobileNetV2.mlmodel` and adjusting input size/labels as needed.

## Notes on Large Files / LFS

The `MobileNetV2.mlmodel` file can be large. For larger ML models or if you hit GitHub size limits, consider adding [Git LFS](https://git-lfs.com/) and tracking `*.mlmodel` files:

```bash
# One-time in the repo
brew install git-lfs # or download installer from git-lfs.com
git lfs install
git lfs track "*.mlmodel"
```

Commit the updated `.gitattributes` after tracking. If you already pushed the model without LFS and need to migrate, use `git lfs migrate`.

## Privacy

If you enable camera/photo access, ensure you keep proper `NSPhotoLibraryUsageDescription` and/or `NSCameraUsageDescription` keys in `Info.plist` with user-friendly descriptions.

## Testing

- `LeafyTests/LeafyTests.swift` — Add unit tests for classifier and model I/O.
- `LeafyUITests/` — UI tests to validate basic flows like picking an image and viewing results.

## Screenshots

Add screenshots of the app here:

- `docs/images/home.png`
- `docs/images/detail.png`

Create the `docs/images/` directory and place PNGs to showcase the UI.

## Roadmap / Ideas

- Improve accuracy with a domain-specific plant model (e.g., fine-tuned on plant datasets).
- Offline persistence of identified plants with Core Data or SwiftData.
- Camera capture flow in addition to photo picker.
- Share/export identified plants.

## License

This project is provided as-is for educational purposes. You can adapt a standard open-source license (e.g., MIT/Apache-2.0) if you plan to share or distribute. Create a `LICENSE` file accordingly.

## Acknowledgements

- Apple Core ML and Vision frameworks.
- Model architecture inspired by MobileNetV2 research.

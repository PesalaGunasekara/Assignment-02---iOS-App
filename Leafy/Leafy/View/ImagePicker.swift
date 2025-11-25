//
//  ImagePicker 2.swift
//  Leafy
//
//  Created by S.A.N.T.Vilochana on 2025-11-15.
//


// In Views/IdentifyView.swift

import SwiftUI
import UIKit // We need this to use UIImagePickerController

// MARK: - 1. The UIKit Bridge (ImagePicker)

/// A SwiftUI view that wraps the UIKit UIImagePickerController.
/// This allows us to use the camera or photo library in SwiftUI.
struct ImagePicker: UIViewControllerRepresentable {
    
    // The source (camera or library)
    var sourceType: UIImagePickerController.SourceType
    
    // Binds the selected image back to the IdentifyView
    @Binding var selectedImage: UIImage?
    
    // Binds the presentation state back to the IdentifyView
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator // The coordinator handles the "didFinishPicking" event
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed
    }

    /// The Coordinator class acts as the delegate for the UIImagePickerController.
    /// It's the "middle-man" that gets the image and passes it back to SwiftUI.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        /// This function is called when the user selects a photo.
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                // Pass the selected image back to our @Binding
                parent.selectedImage = image
            }
            // Dismiss the picker
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        /// This function is called when the user hits "Cancel".
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // FIX: This was the missing part
            // Dismiss the picker
            parent.presentationMode.wrappedValue.dismiss()
        }
    } // <-- FIX: Missing closing brace for Coordinator
} // <-- FIX: Missing closing brace for ImagePicker


// MARK: - 2. The SwiftUI View (IdentifyView)

struct IdentifyView: View {
    // 1. Core Data
    @Environment(\.managedObjectContext) private var viewContext
    
    // 2. View State
    @State private var selectedImage: UIImage?
    @State private var classificationResult: String?
    @State private var isClassifying = false
    
    // 3. Image Picker State
    @State private var isImagePickerShowing = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    // 4. To dismiss this sheet
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // --- 1. Image Display Area ---
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                } else {
                    // Placeholder
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray, style: StrokeStyle(lineWidth: 2, dash: [10]))
                            )
                        
                        VStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("Select a photo to identify")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }

                // --- 2. Action Buttons (Camera/Library) ---
                HStack {
                    Button {
                        self.sourceType = .camera
                        self.isImagePickerShowing = true
                    } label: {
                        Label("Camera", systemImage: "camera.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        self.sourceType = .photoLibrary
                        self.isImagePickerShowing = true
                    } label: {
                        Label("Library", systemImage: "photo.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)

                // --- 3. Classification Section ---
                if isClassifying {
                    // Custom animation (Requirement 2)
                    ProgressView("Identifying...")
                        .padding()
                }
                
                if let result = classificationResult {
                    Text("Result: \(result.capitalized)") // Capitalized for better look
                        .font(.title2)
                        .bold()
                        .padding()
                }

                // --- 4. Main Action Buttons (Classify/Save) ---
                if selectedImage != nil && !isClassifying {
                    Button(action: classifyImage) {
                        Text("Identify Plant")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                }
                
                if classificationResult != nil && classificationResult != "Could not identify." {
                    Button(action: savePlant) {
                        Text("Save to Garden")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green) // Use a different color
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Identify Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            // This is what presents the ImagePicker sheet
            .sheet(isPresented: $isImagePickerShowing) {
                ImagePicker(sourceType: self.sourceType, selectedImage: $selectedImage)
            }
            // Reset classification if image changes
            .onChange(of: selectedImage) { _ in
                classificationResult = nil
            }
        }
    }

    /// Calls the ImageClassifier service
    private func classifyImage() {
        guard let image = selectedImage else { return }
        
        isClassifying = true
        classificationResult = nil
        
        // Call the "brain" (Requirement 6)
        ImageClassifier.classifyImage(image) { result in
            isClassifying = false
            if let result = result {
                self.classificationResult = result
            } else {
                self.classificationResult = "Could not identify."
            }
        }
    }

    /// Saves the new plant to Core Data
    private func savePlant() {
        guard let name = classificationResult, let image = selectedImage else {
            return
        }

        withAnimation {
            // 1. Create a new Core Data object
            let newPlant = SavedPlant(context: viewContext)
            newPlant.id = UUID()
            newPlant.name = name.capitalized
            newPlant.dateAdded = Date()
            
            // 2. Convert UIImage to Data for saving
            // Use a reasonable compression quality
            newPlant.userImage = image.jpegData(compressionQuality: 0.8)

            // 3. Save the context (Requirement 5)
            do {
                try viewContext.save()
                dismiss() // Close the sheet after saving
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
//
//  ImageClassifier.swift
//  Leafy
//
//  Created by S.A.N.T.Vilochana on 2025-11-15.
//


// In Services/ImageClassifier.swift

import SwiftUI
import CoreML
import Vision // Use Vision framework to work with CoreML models

class ImageClassifier {
    
    // --- THIS IS THE MOST IMPORTANT PART ---
    // Change "MobileNetV2" to the exact name of the .mlmodel file you downloaded.
    // For example:
    // guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
    // ----------------------------------------
    private static let model: VNCoreMLModel = {
        guard let model = try? VNCoreMLModel(for: MobileNetV2().model) else {
            fatalError("Failed to load CoreML model. Did you change the name?")
        }
        return model
    }()

    /// Classifies an image and returns the top identifier as a String.
    /// Runs on a background thread and calls the completion handler on the main thread.
    static func classifyImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        
        // 1. Convert UIImage to a CIImage
        guard let ciImage = CIImage(image: image) else {
            print("Failed to convert to CIImage.")
            DispatchQueue.main.async { completion(nil) }
            return
        }
        
        // 2. Create a Vision request
        let request = VNCoreMLRequest(model: model) { (request, error) in
            // 4. Handle the results from the request
            if let error = error {
                print("Vision request failed: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                print("No results found.")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // Success! Return the top result (e.g., "rose, flower")
            // We split to get the primary name, which is often cleaner.
            let topIdentifier = topResult.identifier.components(separatedBy: ",")[0]
            DispatchQueue.main.async {
                completion(topIdentifier)
            }
        }
        
        // 3. Run the request on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage)
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform classification: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
}
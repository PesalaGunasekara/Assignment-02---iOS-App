//
//  PlantRowView.swift
//  Leafy
//
//  Created by S.A.N.T.Vilochana on 2025-11-15.
//


// In Views/PlantRowView.swift

import SwiftUI

struct PlantRowView: View {
    // This view takes one 'SavedPlant' object (from Core Data)
    @ObservedObject var plant: SavedPlant

    var body: some View {
        HStack(spacing: 12) {
            // Safely unwrap the image data from Core Data
            if let imageData = plant.userImage,
               let uiImage = UIImage(data: imageData) {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(8)
            } else {
                // Placeholder if no image exists
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.white)
                            .font(.title)
                    )
            }
            
            VStack(alignment: .leading) {
                // Use nil-coalescing '??' to provide a default value
                Text(plant.name ?? "Unknown Plant")
                    .font(.headline)
                    .bold()
                
                Text("Saved: \(plant.dateAdded ?? Date(), style: .date)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
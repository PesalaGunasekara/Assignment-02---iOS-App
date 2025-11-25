// In Views/PlantDetailView.swift

import SwiftUI

struct PlantDetailView: View {
    // 1. It takes one 'SavedPlant' object to display
    @ObservedObject var plant: SavedPlant

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // 2. Show the plant's image
                if let imageData = plant.userImage,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } else {
                    // Placeholder if image data is missing
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .scaledToFit()
                        .cornerRadius(12)
                        .overlay(
                            Image(systemName: "photo.fill")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                        )
                }

                // 3. Show the plant's details
                Text(plant.name ?? "Unknown Plant")
                    .font(.largeTitle) // Supports Dynamic Type
                    .bold()
                
                Text("Identified on: \(plant.dateAdded ?? Date(), style: .date)")
                    .font(.subheadline) // Supports Dynamic Type
                    .foregroundColor(.secondary)
                
                Spacer() // Pushes content to the top
            }
            .padding()
        }
        .navigationTitle(plant.name ?? "Plant Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

struct PlantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // We have to create a "fake" plant for the preview to work
        let context = PersistenceController.preview.container.viewContext
        let fakePlant = SavedPlant(context: context)
        fakePlant.name = "Preview Plant"
        fakePlant.dateAdded = Date()
        // You could add preview image data here if you wanted
        
        return NavigationView {
            PlantDetailView(plant: fakePlant)
                .environment(\.managedObjectContext, context)
        }
    }
}

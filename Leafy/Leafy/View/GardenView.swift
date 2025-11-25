// In Views/GardenView.swift

import SwiftUI
import CoreData

struct GardenView: View {
    // 1. Get the Core Data context (the 'database' connection)
    @Environment(\.managedObjectContext) private var viewContext

    // 2. Fetch all 'SavedPlant' objects, sort them by date (newest first)
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SavedPlant.dateAdded, ascending: false)],
        animation: .default)
    private var plants: FetchedResults<SavedPlant>

    // 3. State to control showing the camera/identify view
    @State private var isShowingIdentifyView = false

    var body: some View {
        // 4. Use NavigationStack for the app's navigation
        NavigationStack {
            List {
                // 5. Loop over the fetched plants and display them
                ForEach(plants) { plant in
                    NavigationLink(destination: PlantDetailView(plant: plant)) {
                        // Use your custom component here
                        PlantRowView(plant: plant)
                    }
                }
                .onDelete(perform: deletePlants) // This adds the 'swipe to delete' gesture
            }
            .navigationTitle("My Garden")
            .toolbar {
                // Button to open the 'IdentifyView' as a pop-up sheet
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingIdentifyView = true
                    } label: {
                        Label("Identify Plant", systemImage: "camera.fill")
                    }
                }
                // Add an edit button for easier deletion
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $isShowingIdentifyView) {
                // This is where Screen 3 (IdentifyView) will appear
                IdentifyView()
            }
            .overlay {
                // Show a message if the list is empty
                if plants.isEmpty {
                    // FIX: This was 'V', it has been corrected to 'VStack'.
                    VStack {
                        Image(systemName: "leaf.fill")
                            .font(.largeTitle)
                            .padding()
                        Text("Your garden is empty.")
                            .font(.headline)
                        Text("Tap the camera icon to identify your first plant.")
                            .font(.subheadline)
                    }
                    .foregroundColor(.secondary)
                    .padding()
                }
            }
        }
    }
    
    // FIX: Added the missing deletePlants function.
    // This function is called by the .onDelete modifier above.
    private func deletePlants(offsets: IndexSet) {
        withAnimation {
            offsets.map { plants[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Handle the error appropriately
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// MARK: - Preview

struct GardenView_Previews: PreviewProvider {
    static var previews: some View {
        GardenView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

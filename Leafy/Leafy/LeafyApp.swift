// In LeafyApp.swift

import SwiftUI

@main
struct LeafyApp: App {
    // This loads the Core Data "memory" (from Persistence.swift)
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            // 1. Start with GardenView
            GardenView()
                // 2. Inject the Core Data context into the environment
                //    This makes 'viewContext' available to all child views
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

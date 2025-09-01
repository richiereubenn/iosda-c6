//
//  iosda_c6_frontendApp.swift
//  iosda-c6-frontend
//
//  Created by Kevin Christian on 28/08/25.
//

import SwiftUI
import SwiftData

@main
struct iosda_c6_frontendApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ResidentComplaintListView(viewModel: ComplaintListViewModel())
        }
        .modelContainer(sharedModelContainer)
    }
}

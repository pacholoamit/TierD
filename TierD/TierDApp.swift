//
//  TierDApp.swift
//  TierD
//
//  Created by Pacholo Amit on 5/6/25.
//

import SwiftUI
import SwiftData

@main
struct TierDApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Destination.self,
            Tier.self
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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

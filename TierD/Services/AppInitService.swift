//
//  AppInitService.swift
//  TierD
//
//  Created by Pacholo Amit on 5/6/25.
//

import Foundation
import SwiftData




class AppInitService {

    /// Creates and configures a model container for the app
    @MainActor static func createModelContainer() -> ModelContainer {
        let schema = Schema([
            Disk.self,
            Tier.self,
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
    

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}

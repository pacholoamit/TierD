//
//  TierDApp.swift
//  TierD
//
//  Created by Pacholo Amit on 5/6/25.
//

import SwiftData
import SwiftUI

@main
struct TierDApp: App {
    let container: ModelContainer

    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: container.mainContext)
        }
        .modelContainer(container)
    }

    init() {

        container = AppInitService.createModelContainer()

    }
}

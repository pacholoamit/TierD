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
    var sharedModelContainer: ModelContainer = {
        return AppInitService.createModelContainer()
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}




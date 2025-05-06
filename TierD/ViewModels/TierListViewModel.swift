//
//  TierListViewModel.swift
//  TierD
//
//  Created by Pacholo Amit on 5/6/25.
//

import Combine
import Foundation
import SwiftData

/// ViewModel managing the list of tiers and their persistence.
@Observable
class TierListViewModel {
    @Published private(set) var tiers: [Tier] = []
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        list()
    }

    func list() {
        let descriptor = FetchDescriptor<Tier>(
            sortBy: [SortDescriptor(\Tier.level)]
        )
        do {
            tiers = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch tiers: \(error)")
        }
    }
}

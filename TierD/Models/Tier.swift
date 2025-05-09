//
//  Tier.swift
//  TierD
//
//  Created by Pacholo Amit on 5/6/25.
//

import Foundation
import SwiftData

/// Represents an ordered storage tier which groups multiple storage destinations.
@Model
final class Tier {
    /// Unique identifier for the tier.
    @Attribute(.unique) var id: UUID = UUID()


    /// The order index used to sort tiers in the UI.
    @Attribute(.unique) var level: Int
    
    static var all: FetchDescriptor<Tier> {
        FetchDescriptor(sortBy: [SortDescriptor(\Tier.level)])
    }

    /// Destinations associated with this tier; deleting a tier cascades to its destinations.
    @Relationship(deleteRule: .cascade)
    var destinations: [Destination] = []
    
    func addDestination(_ destination: Destination) {
        self.destinations.append(destination)
    }
    
    func removeDestination(_ destination: Destination) {
        self.destinations.removeAll { $0.id == destination.id }
    }
    
    /// Initializes a new Tier with a given name and sort order.
    init(level: Int) {
        self.level = level
    }
}

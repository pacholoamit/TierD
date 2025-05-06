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

    /// Display name for this tier (e.g. "Local Storage", "Archive").
    var name: String

    /// The order index used to sort tiers in the UI.
    @Attribute(.unique) var level: Int
    

    /// Destinations associated with this tier; deleting a tier cascades to its destinations.
    @Relationship(deleteRule: .cascade)
    var destinations: [Destination] = []

    /// Initializes a new Tier with a given name and sort order.
    init(name: String, level: Int) {
        self.name = name
        self.level = level
    }
}

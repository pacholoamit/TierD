//
//  Tier.swift
//  TierD
//
//  Created by Pacholo Amit on 5/6/25.
//

import Foundation
import SwiftData

/// Represents an ordered storage tier which groups multiple storage Disks.
@Model
final class Tier {
    /// Unique identifier for the tier.
    @Attribute(.unique) var id: UUID = UUID()


    /// The order index used to sort tiers in the UI.
    @Attribute(.unique) var level: Int
    
    static var all: FetchDescriptor<Tier> {
        FetchDescriptor(sortBy: [SortDescriptor(\Tier.level)])
    }

    /// Disks associated with this tier; deleting a tier cascades to its Disks.
    @Relationship(deleteRule: .cascade)
    var disks: [Disk] = []
    
    func addUniqueDisk(_ Disk: Disk) {
        if !self.disks.contains(Disk) {
            self.disks.append(Disk)
        }
    }

    func addDisk(_ Disk: Disk) {
        self.disks.append(Disk)
    }
    
    func removeDisk(_ Disk: Disk) {
        self.disks.removeAll { $0.id == Disk.id }
    }
    
    /// Initializes a new Tier with a given name and sort order.
    init(level: Int) {
        self.level = level
    }
}

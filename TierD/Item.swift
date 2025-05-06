//
//  Item.swift
//  TierD
//
//  Created by Pacholo Amit on 5/6/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

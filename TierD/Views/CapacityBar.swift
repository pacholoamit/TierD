//
//  CapacityBar.swift
//  TierD
//
//  Created by Pacholo Amit on 5/10/25.
//


import SwiftData
import SwiftUI

struct CapacityBar: View {
    let usedPercentage: Double
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 6)
                    .foregroundStyle(Color.gray.opacity(0.3))
                
                Capsule()
                    .frame(width: geometry.size.width * usedPercentage, height: 6)
                    .foregroundStyle(Color.accentColor)
            }
        }
    }
}

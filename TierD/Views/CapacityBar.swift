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
    let colorScheme: ColorScheme
    
    private var backgroundColor: Color {
        return colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2)
    }
    
    private var fillColor: Color {
        if usedPercentage > 0.9 {
            return .red
        } else {
            return colorScheme == .dark ? .cyan : .blue
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 6)
                    .foregroundStyle(backgroundColor)
                
                Capsule()
                    .frame(width: geometry.size.width * usedPercentage, height: 6)
                    .foregroundStyle(fillColor)
            }
        }
    }
}
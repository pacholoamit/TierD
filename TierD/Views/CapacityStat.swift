//
//  CapacityStat.swift
//  TierD
//
//  Created by Pacholo Amit on 5/10/25.
//


import SwiftData
import SwiftUI

struct CapacityStat: View {
    let label: String
    let value: String
    let icon: String
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.8))
            
            Text(value)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.medium)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
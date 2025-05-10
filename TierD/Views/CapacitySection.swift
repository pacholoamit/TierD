//
//  CapacitySection.swift
//  TierD
//
//  Created by Pacholo Amit on 5/10/25.
//


import SwiftData
import SwiftUI

struct CapacitySection: View {
    let free: Int64
    let used: Int64
    let total: Int64
    let colorScheme: ColorScheme
    
    private var gradientStartColor: Color {
        return usedPercentage > 0.9 ? .red : (colorScheme == .dark ? .cyan : .blue)
    }
    
    private var gradientEndColor: Color {
        return usedPercentage > 0.9 ? .orange : (colorScheme == .dark ? .blue : .cyan)
    }
    
    private var backgroundColor: Color {
        return colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Storage", colorScheme: colorScheme)
            
            // Capacity bar
            VStack(alignment: .leading, spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(height: 20)
                            .foregroundStyle(backgroundColor)
                        
                        Rectangle()
                            .frame(width: geometry.size.width * usedPercentage, height: 20)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [gradientStartColor, gradientEndColor]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .cornerRadius(6)
                }
                .frame(height: 20)
                
                HStack {
                    Text(usedPercentageText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(formatByteCount(free) + " available")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 8)
            
            // Detailed capacity stats
            HStack {
                CapacityStat(
                    label: "Total",
                    value: formatByteCount(total),
                    icon: "internaldrive",
                    colorScheme: colorScheme
                )
                
                Divider()
                
                CapacityStat(
                    label: "Used",
                    value: formatByteCount(used),
                    icon: "internaldrive.fill",
                    colorScheme: colorScheme
                )
                
                Divider()
                
                CapacityStat(
                    label: "Free",
                    value: formatByteCount(free),
                    icon: "internaldrive.badge.plus",
                    colorScheme: colorScheme
                )
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(10)
        }
    }
    
    private var usedPercentage: Double {
        if total > 0 {
            return Double(used) / Double(total)
        }
        return 0
    }
    
    private var usedPercentageText: String {
        if total > 0 {
            let percentage = Double(used) / Double(total) * 100
            return String(format: "%.1f%% used", percentage)
        }
        return "Unknown"
    }
    
    // Helper function to format byte count
    private func formatByteCount(_ byteCount: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        
        return formatter.string(fromByteCount: byteCount)
    }
}
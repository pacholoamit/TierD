//
//  DiskRow.swift
//  TierD
//
//  Created by Pacholo Amit on 5/10/25.
//

import SwiftUI

struct DiskRow: View {
    let disk: Disk
    let colorScheme: ColorScheme
    
    // Mock capacity values since they're no longer in the model
#warning ("Update this with correct values")
    private var mockFree: Int64 { return 50_000_000_000 }
    private var mockTotal: Int64 { return 250_000_000_000 }
    private var mockUsed: Int64 { return mockTotal - mockFree }
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
                .font(.system(size: 20))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(disk.name)
                    .fontWeight(.medium)
                
                Text(usageInfo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            CapacityBar(
                usedPercentage: usedPercentage,
                colorScheme: colorScheme
            )
            .frame(width: 60, height: 6)
        }
        .padding(.vertical, 4)
    }
    
    private var iconName: String {
        switch disk.type {
        case .local:
            return "internaldrive"
        case .external(let type):
            switch type {
            case .usb:
                return "externaldrive"
            case .ssd:
                return "externaldrive.fill"
            case .hdd:
                return "externaldrive.fill.badge.timemachine"
            }
        case .remote:
            return "network"
        case .cloud:
            return "cloud"
        }
    }
    
    private var iconColor: Color {
        switch disk.type {
        case .local:
            return colorScheme == .dark ? .blue : .blue
        case .external:
            return colorScheme == .dark ? .green : .green
        case .remote:
            return colorScheme == .dark ? .purple : .purple
        case .cloud:
            return colorScheme == .dark ? .cyan : .cyan
        }
    }
    
    private var usageInfo: String {
        return "\(formatByteCount(mockFree)) free of \(formatByteCount(mockTotal))"
    }
    
    private var usedPercentage: Double {
        return Double(mockUsed) / Double(mockTotal)
    }
    
    // Helper function to format byte count since it's no longer in disk
    private func formatByteCount(_ byteCount: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        
        return formatter.string(fromByteCount: byteCount)
    }
}

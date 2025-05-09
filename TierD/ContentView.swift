//
//  ContentView.swift
//  TierD
//
//  Created by Pacholo Amit on 5/6/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    @Query(Tier.all) private var tiers: [Tier]
    
    @State private var selectedDestination: Destination?
    
    // System-adaptive accent colors
    private var accentColor: Color {
        return Color.accentColor
    }
    
    private var secondaryAccentColor: Color {
        return colorScheme == .dark ? Color.cyan : Color.blue
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar showing tiers and destinations
            List(selection: $selectedDestination) {
                ForEach(tiers) { tier in
                    Section(header: tierHeader(tier: tier)) {
                        ForEach(tier.destinations) { destination in
                            DestinationRow(
                                destination: destination,
                                colorScheme: colorScheme
                            )
                            .tag(destination)
                        }
                    }
                }
            }
            .navigationTitle("Storage Tiers")
            .listStyle(SidebarListStyle())
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        // Future action for adding new destination
                    }) {
                        Label("Add Destination", systemImage: "plus")
                    }
                    .tint(accentColor)
                }
            }
        } detail: {
            // Detail view showing selected destination
            if let destination = selectedDestination {
                DestinationDetailView(
                    destination: destination,
                    colorScheme: colorScheme
                )
            } else {
                ContentUnavailableView {
                    Label("No Storage Selected", systemImage: "externaldrive")
                        .foregroundStyle(accentColor)
                } description: {
                    Text("Select a storage destination to view details.")
                }
            }
        }
        .tint(accentColor) // Apply accent color to navigation elements
    }
    
    private func tierHeader(tier: Tier) -> some View {
        HStack {
            Text("Tier \(tier.level)")
                .font(.headline)
                .foregroundStyle(accentColor.opacity(0.8))
            
            Spacer()
            
            if !tier.destinations.isEmpty {
                Text("\(tier.destinations.count) storage\(tier.destinations.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct DestinationRow: View {
    let destination: Destination
    let colorScheme: ColorScheme
    
    // Mock capacity values since they're no longer in the model
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
                Text(destination.name)
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
        switch destination.type {
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
        switch destination.type {
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
    
    // Helper function to format byte count since it's no longer in Destination
    private func formatByteCount(_ byteCount: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        
        return formatter.string(fromByteCount: byteCount)
    }
}

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

struct DestinationDetailView: View {
    let destination: Destination
    let colorScheme: ColorScheme
    
    // Mock capacity values since they're no longer in the model
    private var mockFree: Int64 { return 50_000_000_000 }
    private var mockTotal: Int64 { return 250_000_000_000 }
    private var mockUsed: Int64 { return mockTotal - mockFree }
    
    private var iconColor: Color {
        switch destination.type {
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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with icon and name
                HStack(spacing: 16) {
                    Image(systemName: iconName)
                        .font(.system(size: 40))
                        .foregroundStyle(iconColor)
                    
                    VStack(alignment: .leading) {
                        Text(destination.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(typeDescription)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom)
                
                // Capacity information
                CapacitySection(
                    free: mockFree,
                    used: mockUsed,
                    total: mockTotal,
                    colorScheme: colorScheme
                )
                
                // Path info
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Location", colorScheme: colorScheme)
                    
                    Text(destination.url)
                        .font(.system(.body, design: .monospaced))
                        .padding(12)
                        .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(destination.name)
    
    }
    
    private var iconName: String {
        switch destination.type {
        case .local:
            return "internaldrive.fill"
        case .external(let type):
            switch type {
            case .usb:
                return "externaldrive.fill"
            case .ssd:
                return "externaldrive.fill.badge.plus"
            case .hdd:
                return "externaldrive.fill.badge.timemachine"
            }
        case .remote:
            return "network"
        case .cloud(let type):
            switch type {
            case .awsS3:
                return "cloud.fill"
            case .azureBlob:
                return "cloud.fill"
            case .googleCloudStorage:
                return "cloud.fill"
            case .microsoftOneDrive:
                return "cloud.fill"
            case .dropbox:
                return "cloud.fill"
            }
        }
    }
    
    private var typeDescription: String {
        switch destination.type {
        case .local:
            return "Local Storage"
        case .external(let type):
            switch type {
            case .usb:
                return "USB External Drive"
            case .ssd:
                return "External SSD"
            case .hdd:
                return "External Hard Drive"
            }
        case .remote(let type):
            switch type {
            case .sftp:
                return "SFTP Remote Storage"
            case .webdav:
                return "WebDAV Remote Storage"
            }
        case .cloud(let type):
            switch type {
            case .awsS3:
                return "AWS S3 Cloud Storage"
            case .azureBlob:
                return "Azure Blob Storage"
            case .googleCloudStorage:
                return "Google Cloud Storage"
            case .microsoftOneDrive:
                return "Microsoft OneDrive"
            case .dropbox:
                return "Dropbox"
            }
        }
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

struct SectionHeader: View {
    let title: String
    let colorScheme: ColorScheme
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.8) : .secondary)
    }
}

#Preview {
    ContentView()
}

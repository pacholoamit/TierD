//
//  DiskDetailView.swift
//  TierD
//
//  Created by Pacholo Amit on 5/10/25.
//


import SwiftData
import SwiftUI

struct DiskDetailView: View {
    let disk: Disk
    let colorScheme: ColorScheme
    
    // Mock capacity values since they're no longer in the model
    private var mockFree: Int64 { return 50_000_000_000 }
    private var mockTotal: Int64 { return 250_000_000_000 }
    private var mockUsed: Int64 { return mockTotal - mockFree }
    
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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with icon and name
                HStack(spacing: 16) {
                    Image(systemName: iconName)
                        .font(.system(size: 40))
                        .foregroundStyle(iconColor)
                    
                    VStack(alignment: .leading) {
                        Text(disk.name)
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
                    
                    Text(disk.url)
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
        .navigationTitle(disk.name)
    
    }
    
    private var iconName: String {
        switch disk.type {
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
        switch disk.type {
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

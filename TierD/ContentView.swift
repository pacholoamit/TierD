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
    @State private var fileManagerService = FileManagerService()

    @State private var selectedDisk: Disk?

    // System-adaptive accent colors
    private var accentColor: Color {
        return Color.accentColor
    }

    var body: some View {
        NavigationSplitView {
            // Sidebar showing tiers and disks
            List(selection: $selectedDisk) {
                ForEach(fileManagerService.volumes) { disk in
                    Text(disk.name)

                }
                //                ForEach(tiers) { tier in
                //                    Section(header: tierHeader(tier: tier)) {
                //                        ForEach(fileM) { disk in
                //                            DiskRow(
                //                                disk: disk,
                //                                colorScheme: colorScheme
                //                            )
                //                            .tag(disk)
                //                        }
                //                    }
                //                }
            }
            .navigationTitle("Storage Tiers")
            .listStyle(SidebarListStyle())
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        // Future action for adding new disk
                    }) {
                        Label("Add disk", systemImage: "plus")
                    }
                    .tint(accentColor)
                }
            }
        } detail: {
            // Detail view showing selected disk
            if let disk = selectedDisk {
                DiskDetailView(
                    disk: disk,
                    colorScheme: colorScheme
                )
            } else {
                ContentUnavailableView {
                    Label("No Storage Selected", systemImage: "externaldrive")
                        .foregroundStyle(accentColor)
                } description: {
                    Text("Select a storage disk to view details.")
                }
            }
        }
        .tint(accentColor)  // Apply accent color to navigation elements
    }

    private func tierHeader(tier: Tier) -> some View {
        HStack {
            Text("Tier \(tier.level)")
                .font(.headline)
                .foregroundStyle(accentColor.opacity(0.8))

            Spacer()

            if !tier.disks.isEmpty {
                Text(
                    "\(tier.disks.count) storage\(tier.disks.count == 1 ? "" : "s")"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ContentView()
}

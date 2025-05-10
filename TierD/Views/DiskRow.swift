//
//  DiskRow.swift
//  TierD
//
//  Created by Pacholo Amit on 5/10/25.
//

import SwiftUI

struct DiskRow: View {
    let disk: Disk


    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundStyle(Color.accentColor)
                .font(.system(size: 20))
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(disk.name)
                    .fontWeight(.medium)

                Text("\(disk.formattedAvailableCapacity) free of \(disk.formattedTotalCapacity)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            CapacityBar(
                usedPercentage: disk.percentageUsed
            )
            .frame(width: 60, height: 6)
        }
        .padding(.vertical, 4)
    }

    private var iconName: String {
        switch disk.type {
        case .local:
            return "internaldrive"
        case .unknown:
            return "questionmark"
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



}

//
//  FIleManagerService.swift
//  TierD
//
//  Created by Pacholo Amit on 5/9/25.
//

import Foundation
import Observation

enum FileManagerServiceError: String, Error, Hashable {
    case FailedToScanVolumes = "Failed to scan volumes"
    case FailedToGetVolumeResourceKeyValue =
        "Failed to get volume resource key value"
}

@Observable public final class FileManagerService {

    public var volumes: [Disk] = []

    private static var fileManager: FileManager = FileManager.default

    init() {
        self.volumes = try! FileManagerService.scanVolumes()
    }

    static private func scanVolumes() throws -> [Disk] {
        var volumes: [Disk] = []
        let keys: Set<URLResourceKey> = [
            .volumeNameKey,
            .volumeAvailableCapacityKey,
            .volumeTotalCapacityKey,
            .volumeTypeNameKey,
            .volumeSubtypeKey,
            .volumeIsEjectableKey,
            .volumeIsLocalKey,
            .volumeIsRemovableKey,
        ]

        guard
            let urls = fileManager.mountedVolumeURLs(
                includingResourceValuesForKeys: Array(keys),
                options: [.skipHiddenVolumes]
            )
        else {
            throw FileManagerServiceError.FailedToScanVolumes
        }

        for url in urls {
            do {
                let rv = try url.resourceValues(forKeys: keys)

                let usedCapactiy =
                    rv.volumeAvailableCapacity?
                    .subtractingReportingOverflow(
                        rv.volumeTotalCapacity ?? 0
                    ).partialValue ?? 0
                
                let newDisk =     Disk(
                    name: rv.volumeName,
                    url: rv.path,
                    availableCapacity: rv.volumeAvailableCapacity,
                    totalCapacity: rv.volumeTotalCapacity,
                    usedCapacity: usedCapactiy,
                    isEjectable: rv.volumeIsEjectable,
                    isLocal: rv.volumeIsLocal,
                    isRemovable: rv.volumeIsRemovable,
                    type: .local
                )

                volumes.append(
                    newDisk
                )
                
     
                // Print detailed disk information
                print("""
                ✅ Added Disk:
                   Name: \(rv.volumeName ?? "Unknown")
                   Path: \(url.path)
                   Storage: \(newDisk.formattedUsedCapacity) used of \(newDisk.formattedTotalCapacity) (\(newDisk.formattedPercentageUsed)%)
                   Available: \(newDisk.formattedAvailableCapacity)
                   Type: \(rv.volumeTypeName ?? "Unknown")
                   IsLocal: \(String(describing: rv.volumeIsLocal))
                   IsRemovable: \(String(describing: rv.volumeIsRemovable))
                   IsEjectable: \(String(describing: rv.volumeIsEjectable))
                """)
            } catch {
                // Log and continue on error
                print("⚠️ Skipping volume at \(url.path): \(error)")
            }
        }
        return volumes
    }
    
 
}

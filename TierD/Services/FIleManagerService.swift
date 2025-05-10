//
//  FIleManagerService.swift
//  TierD
//
//  Created by Pacholo Amit on 5/9/25.
//

import Foundation
import Observation
import SwiftData

enum FileManagerServiceError: String, Error, Hashable {
    case FailedToScanVolumes = "Failed to scan volumes"
    case FailedToGetVolumeResourceKeyValue =
        "Failed to get volume resource key value"
}

@Observable public final class FileManagerService {

    public var volumes: [Disk] = []
    var modelContext: ModelContext
    private static var fileManager: FileManager = FileManager.default

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.volumes = try! FileManagerService.scanVolumes(in: modelContext)
    }

    static private func scanVolumes(in context: ModelContext) throws -> [Disk] {
        
        let tier1 = Tier(level: 1)
        let tier2 = Tier(level: 2)
        
        context.insert(tier1)
        context.insert(tier2)
        
        
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
            .volumeIsRootFileSystemKey
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

                // Determine the storage type based on volume information
                let storageType = determineStorageType(
                    isLocal: rv.volumeIsLocal,
                    isRemovable: rv.volumeIsRemovable,
                    isEjectable: rv.volumeIsEjectable,
                    typeName: rv.volumeTypeName,
                    path: url.path
                )

                let newDisk = Disk(
                    name: rv.volumeName,
                    url: url.path,
                    availableCapacity: rv.volumeAvailableCapacity,
                    totalCapacity: rv.volumeTotalCapacity,
                    usedCapacity: usedCapactiy,
                    isEjectable: rv.volumeIsEjectable,
                    isLocal: rv.volumeIsLocal,
                    isRemovable: rv.volumeIsRemovable,
                    type: storageType
                )
                
                volumes.append(newDisk)
                
                if (rv.volumeIsRootFileSystem ?? false) {
                    tier1.addUniqueDisk(newDisk)
                } else {
                    tier2.addUniqueDisk(newDisk)
                }

        

                // Print detailed disk information
                print(
                    """
                    ✅ Added Disk:
                       Name: \(rv.volumeName ?? "Unknown")
                       Path: \(url.path)
                       Storage: \(newDisk.formattedUsedCapacity) used of \(newDisk.formattedTotalCapacity) (\(newDisk.formattedPercentageUsed)%)
                       Available: \(newDisk.formattedAvailableCapacity)
                       Type: \(rv.volumeTypeName ?? "Unknown")
                       Storage Type: \(storageType)
                       IsLocal: \(String(describing: rv.volumeIsLocal))
                       IsRemovable: \(String(describing: rv.volumeIsRemovable))
                       IsEjectable: \(String(describing: rv.volumeIsEjectable))
                    """
                )
            } catch {
                // Log and continue on error
                print("⚠️ Skipping volume at \(url.path): \(error)")
            }
        }
        return volumes
    }

    // Helper function to determine storage type based on volume information
    #warning("Make this more realistic later")
    private static func determineStorageType(
        isLocal: Bool?,
        isRemovable: Bool?,
        isEjectable: Bool?,
        typeName: String?,
        path: String
    ) -> StorageType {
        // Default to unknown if we can't determine
        guard let isLocal = isLocal else { return .unknown }

        // If it's not local, it might be a remote or cloud storage
        if !isLocal {
            // Check for common remote protocols in path or type
            if path.lowercased().contains("smb://")
                || path.lowercased().contains("afp://")
                || (typeName?.lowercased().contains("network") ?? false)
            {
                return .remote(.sftp)  // Default to sftp as subtype
            }

            // Could be cloud storage
            if (typeName?.lowercased().contains("icloud") ?? false)
                || (typeName?.lowercased().contains("cloud") ?? false)
            {
                return .cloud(.dropbox)  // Default to dropbox as subtype
            }

            return .remote(.sftp)  // Default remote type
        }

        // Local but removable is likely an external drive
        if isRemovable == true || isEjectable == true {
            // Try to determine type of external storage
            if let typeName = typeName?.lowercased() {
                if typeName.contains("usb") {
                    return .external(.usb)
                } else if typeName.contains("ssd") {
                    return .external(.ssd)
                } else if typeName.contains("thunderbolt") {
                    return .external(.ssd)  // Typically high-speed
                }
            }

            // Default to HDD for other removable storage
            return .external(.hdd)
        }

        // Local and not removable is the internal storage
        return .local
    }

}

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
    case FailedToGetVolumeResourceKeyValue = "Failed to get volume resource key value"
}

@Observable
class FileManagerServiceVolume {
    var name: String
    var path: String
    var availableCapacity: Int
    var totalCapacity: Int
    var typeName: String
    var subtype: Int
    var isEjectable: Bool
    var isLocal: Bool
    var isRemovable: Bool
    
    init(
        name: String?,
        path: String?,
        availableCapacity: Int?,
        totalCapacity: Int?,
        typeName: String?,
        subtype: Int?,
        isEjectable: Bool?,
        isLocal: Bool?,
        isRemovable: Bool?
    ) {
        self.name = name ?? "Unknown"
        self.path = path ?? "Unknown"
        self.availableCapacity = availableCapacity ?? 0
        self.totalCapacity = totalCapacity ?? 0
        self.typeName = typeName ?? "Unknown"
        self.subtype = subtype ?? 0
        self.isEjectable = isEjectable ?? false
        self.isLocal = isLocal ?? false
        self.isRemovable = isRemovable ?? false
    }
}

@Observable
class FileManagerService {

    var volumes: [FileManagerServiceVolume] = []

    private static var fileManager: FileManager = FileManager.default

    init()  {
        self.volumes = try! FileManagerService.scanVolumes()
    }

    static private func scanVolumes() throws -> [FileManagerServiceVolume] {
        var volumes: [FileManagerServiceVolume] = []
        let keys: Set<URLResourceKey> = [
            .volumeNameKey,
            .volumeAvailableCapacityKey,
            .volumeTotalCapacityKey,
            .volumeTypeNameKey,
            .volumeSubtypeKey,
            .volumeIsEjectableKey,
            .volumeIsLocalKey,
            .volumeIsRemovableKey
        ]
        
        guard let urls = fileManager.mountedVolumeURLs(
            includingResourceValuesForKeys: Array(keys),
            options: [.skipHiddenVolumes]
        ) else {
            throw FileManagerServiceError.FailedToScanVolumes
        }
        

        for url in urls {
            do {
                let rv = try url.resourceValues(forKeys: keys)
                volumes.append(.init(
                    name:               rv.volumeName,
                    path:               url.path,
                    availableCapacity:  rv.volumeAvailableCapacity,
                    totalCapacity:      rv.volumeTotalCapacity,
                    typeName:           rv.volumeTypeName,
                    subtype:            rv.volumeSubtype,
                    isEjectable:        rv.volumeIsEjectable,
                    isLocal:            rv.volumeIsLocal,
                    isRemovable:        rv.volumeIsRemovable
                ))
                print("✅ Scanned volume \(rv.volumeName ?? "Unknown") at \(url.path)")
            } catch {
                // Log and continue on error
                print("⚠️ Skipping volume at \(url.path): \(error)")
            }
        }
        return volumes
    }
}

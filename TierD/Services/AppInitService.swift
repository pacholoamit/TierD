//
//  AppInitService.swift
//  TierD
//
//  Created by Pacholo Amit on 5/6/25.
//

import Foundation
import SwiftData



enum AppInitError: String, Error, Hashable {
    case FailedToScanVolumes = "Failed to scan volumes"
    
}

class AppInitService {

    static private func scanVolumes(
        in context: ModelContext,
    ) throws {
        let baseTier = Tier(level: 1)
        context.insert(baseTier)
        
        // Get all mounted volumes
        let fileManager = FileManager.default
        let keys: [URLResourceKey] = [
            .volumeNameKey,
            .volumeURLKey,
            .volumeAvailableCapacityKey,
            .volumeTotalCapacityKey,
            .volumeIsLocalKey,
            .volumeTypeNameKey,
            .volumeIsRemovableKey,
        ]
        
        guard let volumeURLs = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: keys, options: []) else {
            throw AppInitError.FailedToScanVolumes
        }
        
        print("Found \(volumeURLs.count) mounted volumes, filtering for physical drives only:")
        
        // Keep track of paths we've already processed to avoid duplicates
        var processedPaths = Set<String>()
        
        // Check for existing destinations to avoid duplicates on app restart
        let existingDestinations = try? context.fetch(FetchDescriptor<Destination>())
        let existingPaths = Set(existingDestinations?.map { $0.url } ?? [])
        
        processedPaths.formUnion(existingPaths)
        
        for volumeURL in volumeURLs {
            do {
                let path = volumeURL.path
                
                // Skip if this path has already been processed or exists in the database
                if processedPaths.contains(path) {
                    print("Skipping volume at \(path) (already exists in database)")
                    continue
                }
                
                let resourceValues = try volumeURL.resourceValues(forKeys: Set(keys))
                
                let volumeName = resourceValues.volumeName ?? "Unknown"
                let isLocal = resourceValues.volumeIsLocal ?? false
                let isRemovable = resourceValues.volumeIsRemovable ?? false
                let volumeTypeName = resourceValues.volumeTypeName ?? "Unknown"
                
                // Skip virtual or non-physical volumes based on various criteria
                var shouldSkip = false
                
                // Skip volumes that don't have capacity information (often virtual mounts)
                if resourceValues.volumeAvailableCapacity == nil || resourceValues.volumeTotalCapacity == nil {
                    shouldSkip = true
                }
                
                // Skip volumes with certain path patterns that indicate they're not physical drives
                let pathsToSkip = [
                    "/System/Volumes/Data/", // Data volume that's part of the system
                    "/System/Volumes/Preboot", // Preboot volume
                    "/System/Volumes/VM", // Virtual memory volume
                    "/System/Volumes/Update", // Update volume
                ]
                
                if pathsToSkip.contains(where: { path.hasPrefix($0) }) {
                    shouldSkip = true
                }
                
                // Skip volumes with names that indicate they're applications or images
                let namesToSkip = [".dmg", ".app", ".sparseimage", ".sparsebundle"]
                if namesToSkip.contains(where: { volumeName.lowercased().contains($0) }) {
                    shouldSkip = true
                }
                
                // Skip if it's not in /Volumes (most physical drives are mounted here)
                // but make an exception for the root volume
                if !path.hasPrefix("/Volumes/") && path != "/" {
                    shouldSkip = true
                }
                
                // Skip if we decided this isn't a physical drive
                if shouldSkip {
                    print("Skipping volume: \(volumeName) at \(path) (not a physical drive)")
                    continue
                }
                
                print("-------------------")
                print("Volume: \(volumeName)")
                print("Path: \(path)")
                print("Type: \(volumeTypeName)")
                print("Is Local: \(isLocal)")
                print("Is Removable: \(isRemovable)")
                
                if let availableCapacity = resourceValues.volumeAvailableCapacity {
                    let availableGB = Double(availableCapacity) / (1024 * 1024 * 1024)
                    print("Available: \(String(format: "%.2f GB", availableGB))")
                }
                
                if let totalCapacity = resourceValues.volumeTotalCapacity {
                    let totalGB = Double(totalCapacity) / (1024 * 1024 * 1024)
                    print("Total: \(String(format: "%.2f GB", totalGB))")
                }
                
                // Determine the storage type based on volume properties
                var storageType: StorageType = .local
                
                if isRemovable {
                    if volumeTypeName.lowercased().contains("usb") {
                        storageType = .external(.usb)
                    } else if volumeTypeName.lowercased().contains("ssd") {
                        storageType = .external(.ssd)
                    } else {
                        storageType = .external(.hdd)
                    }
                }
                
                let destination = Destination(
                    name: volumeName,
                    url: path,
                    type: storageType
                )
                
                // Add the destination to the base tier
                baseTier.addDestination(destination)
                
                // Mark this path as processed
                processedPaths.insert(path)
                
            } catch {
                print("Error retrieving resource values for \(volumeURL.path): \(error)")
            }
        }
    }

    /// Initializes the base tier and default destinations
    static func initialize(in context: ModelContext) {


        try! scanVolumes(in: context)
    }

    /// Creates and configures a model container for the app
    @MainActor static func createModelContainer() -> ModelContainer {
        let schema = Schema([
            Destination.self,
            Tier.self,
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            initialize(in: container.mainContext)

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}

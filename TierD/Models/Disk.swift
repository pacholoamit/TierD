//
//  Disk.swift
//  TierD
//
//  Created by Pacholo Amit on 5/6/25.
//

import Foundation
import SwiftData

enum CloudStorageType: String, Codable, CaseIterable {
    case awsS3 = "s3"
    case azureBlob = "azureblob"
    case googleCloudStorage = "google-cloud-storage"
    case microsoftOneDrive = "microsoft-onedrive"
    case dropbox = "dropbox"
}

enum RemoteStorageType: String, Codable, CaseIterable {
    case sftp = "sftp"
    case webdav = "webdav"
}

enum ExternalStorageType: String, Codable, CaseIterable {
    case usb = "usb"
    case ssd = "ssd"
    case hdd = "hdd"
}

/// Enumeration of supported storage Disk types.
enum StorageType: Codable, Hashable {
    /// Local macOS drive (Tier 1 storage).
    case local
    /// External SD / HD
    case external(ExternalStorageType)
    /// Remote Server (SFTP)
    case remote(RemoteStorageType)
    /// Cloud-based storage such as AWS S3 or Azure Blob (Tier 3+ storage).
    case cloud(CloudStorageType)

    case unknown
}

struct CloudStorageTypeS3Configuration: Codable {
    var accessKeyId: String
    var secretAccessKey: String
    var region: String?
    var bucket: String
    var endpoint: URL?
}

struct RemoteStorageTypeSFTPConfiguration: Codable {
    var host: String
    var username: String
    var password: String
    var privateKey: String?
    var port: Int?
    var rootPath: String?
}

enum Credentials: Codable {
    case s3(CloudStorageTypeS3Configuration)
    case sftp(RemoteStorageTypeSFTPConfiguration)

    private enum CodingKeys: String, CodingKey { case type, config }
    private enum Kind: String, Codable { case s3, sftp }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .type) {
        case .s3:
            let cfg = try container.decode(
                CloudStorageTypeS3Configuration.self,
                forKey: .config
            )
            self = .s3(cfg)
        case .sftp:
            let cfg = try container.decode(
                RemoteStorageTypeSFTPConfiguration.self,
                forKey: .config
            )
            self = .sftp(cfg)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .s3(let cfg):
            try container.encode(Kind.s3, forKey: .type)
            try container.encode(cfg, forKey: .config)
        case .sftp(let cfg):
            try container.encode(Kind.sftp, forKey: .type)
            try container.encode(cfg, forKey: .config)
        }
    }
}

/// Represents a specific storage endpoint within a tier.
@Model
public final class Disk {
    /// Unique identifier for the Disk.
    @Attribute(.unique)
   public var id: UUID = UUID()

    /// User-visible name for this Disk configuration.
    var name: String

    /// Represents the reference to the disk via url, if any
    @Attribute(.unique)
    var url: String

    var availableCapacity: Int
    
    var formattedAvailableCapacity: String {
        return Disk.formatByteCount(availableCapacity)
    }
    
    var formattedTotalCapacity: String {
        return Disk.formatByteCount(totalCapacity)
    }
    
    var formattedUsedCapacity: String {
        return Disk.formatByteCount(usedCapacity)
    }
    
    var formattedPercentageUsed: String {
        let percentageUsed: Double = Double(usedCapacity) / Double(totalCapacity) * 100
        return String(format: "%.1f%%", percentageUsed)
    }

    var totalCapacity: Int

    var usedCapacity: Int

    var isEjectable: Bool

    var isLocal: Bool

    var isRemovable: Bool

    /// The storage type indicating local, remote server, or cloud.
    var type: StorageType

    /// Optional credentials or token string required for authentication.
    var credentials: Credentials?
    /// Inverse relationship back to the owning tier; nullify on delete.
    @Relationship(deleteRule: .nullify, inverse: \Tier.disks)
    var tier: Tier?

    // Helper function to format byte count
    private static func formatByteCount(_ byteCount: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        
        return formatter.string(fromByteCount: Int64(byteCount))
    }
    
    init(
        name: String?,
        url: String?,
        availableCapacity: Int?,
        totalCapacity: Int?,
        usedCapacity: Int?,
        isEjectable: Bool?,
        isLocal: Bool?,
        isRemovable: Bool?,
        type: StorageType?,
        credentials: Credentials? = nil,
    ) {
        self.name = name ?? "Unknown"
        self.url = url ?? "Unknown"
        self.availableCapacity = availableCapacity ?? 0
        self.totalCapacity = totalCapacity ?? 0
        self.usedCapacity = usedCapacity ?? 0
        self.isEjectable = isEjectable ?? false
        self.isLocal = isLocal ?? false
        self.isRemovable = isRemovable ?? false
        self.type = type ?? .unknown
        self.credentials = credentials ?? nil
    }

 
}

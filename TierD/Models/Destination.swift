//
//  Destination.swift
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

/// Enumeration of supported storage destination types.
enum StorageType: Codable {
    /// Local macOS drive (Tier 1 storage).
    case local
    /// External SD / HD
    case external(ExternalStorageType)
    /// Remote Server (SFTP)
    case remote(RemoteStorageType)
    /// Cloud-based storage such as AWS S3 or Azure Blob (Tier 3+ storage).
    case cloud(CloudStorageType)
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
            let cfg = try container.decode(CloudStorageTypeS3Configuration.self, forKey: .config)
            self = .s3(cfg)
        case .sftp:
            let cfg = try container.decode(RemoteStorageTypeSFTPConfiguration.self, forKey: .config)
            self = .sftp(cfg)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .s3(let cfg):
            try container.encode(Kind.s3, forKey: .type)
            try container.encode(cfg,   forKey: .config)
        case .sftp(let cfg):
            try container.encode(Kind.sftp, forKey: .type)
            try container.encode(cfg,       forKey: .config)
        }
    }
}


/// Represents a specific storage endpoint within a tier.
@Model
final class Destination {
    /// Unique identifier for the destination.
    @Attribute(.unique)
    var id: UUID = UUID()

    /// User-visible name for this destination configuration.
    var name: String

    /// The storage type indicating local, remote server, or cloud.
    var type: StorageType

    /// URL endpoint for the storage (file path, FTP URL, or cloud bucket URL).
    var url: URL?

    /// Optional credentials or token string required for authentication.
    var credentials: Credentials
    /// Inverse relationship back to the owning tier; nullify on delete.
    @Relationship(deleteRule: .nullify, inverse: \Tier.destinations)
    var tier: Tier


    /// Initializes a new Destination attached to a given tier.
    init(name: String,
         type: StorageType,
         credentials: Credentials,
         tier: Tier) {
        self.name = name
        self.type = type
        self.credentials = credentials
        self.tier = tier
    }
}

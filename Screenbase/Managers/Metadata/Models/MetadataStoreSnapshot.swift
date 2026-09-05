//
//  MetadataStoreSnapshot.swift
//  Screenbase
//

import Foundation

struct MetadataStoreSnapshot: Codable, Equatable, Sendable {
    var screenshots: [ScreenshotRecord]
    var collections: [CollectionRecord]
    var tags: [TagRecord]

    static let empty = MetadataStoreSnapshot(screenshots: [], collections: [], tags: [])
}

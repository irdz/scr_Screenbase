//
//  ScreenshotRecord.swift
//  Screenbase
//

import Foundation

/// Local + Firestore metadata for a discovered screenshot asset.
struct ScreenshotRecord: Codable, Equatable, Identifiable, Sendable, Hashable {
    var id: String
    var assetLocalIdentifier: String
    var captureDate: Date?
    var annotationText: String?
    var collectionIds: [String]
    var tagIds: [String]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String,
        assetLocalIdentifier: String,
        captureDate: Date? = nil,
        annotationText: String? = nil,
        collectionIds: [String] = [],
        tagIds: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.assetLocalIdentifier = assetLocalIdentifier
        self.captureDate = captureDate
        self.annotationText = annotationText
        self.collectionIds = collectionIds
        self.tagIds = tagIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(discovered: DiscoveredScreenshot, now: Date = Date()) {
        self.init(
            id: discovered.assetLocalIdentifier,
            assetLocalIdentifier: discovered.assetLocalIdentifier,
            captureDate: discovered.creationDate,
            createdAt: now,
            updatedAt: now
        )
    }

    enum CodingKeys: String, CodingKey {
        case id
        case assetLocalIdentifier = "asset_local_identifier"
        case captureDate = "capture_date"
        case annotationText = "annotation_text"
        case collectionIds = "collection_ids"
        case tagIds = "tag_ids"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    static let mock = ScreenshotRecord(
        id: "MOCK/ASSET-1",
        assetLocalIdentifier: "MOCK/ASSET-1",
        captureDate: Date(timeIntervalSince1970: 1_700_000_000),
        annotationText: "Login flow",
        collectionIds: ["col_1"],
        tagIds: ["tag_1"],
        createdAt: Date(timeIntervalSince1970: 1_700_000_000),
        updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
    )
}

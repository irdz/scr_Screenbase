//
//  MockMetadataService.swift
//  Screenbase
//

import Foundation

@MainActor
final class MockMetadataService: MetadataService {
    private(set) var syncedScreenshots: [ScreenshotRecord] = []
    private(set) var deletedScreenshotIds: [String] = []
    private(set) var syncedCollections: [CollectionRecord] = []
    private(set) var deletedCollectionIds: [String] = []
    private(set) var syncedTags: [TagRecord] = []
    private(set) var deletedTagIds: [String] = []
    var shouldFailSync = false

    func syncScreenshot(_ record: ScreenshotRecord, userId _: String) async throws {
        try throwIfNeeded()
        if let index = syncedScreenshots.firstIndex(where: { $0.id == record.id }) {
            syncedScreenshots[index] = record
        } else {
            syncedScreenshots.append(record)
        }
    }

    func deleteScreenshot(id: String, userId _: String) async throws {
        try throwIfNeeded()
        syncedScreenshots.removeAll { $0.id == id }
        deletedScreenshotIds.append(id)
    }

    func syncCollection(_ record: CollectionRecord, userId _: String) async throws {
        try throwIfNeeded()
        if let index = syncedCollections.firstIndex(where: { $0.id == record.id }) {
            syncedCollections[index] = record
        } else {
            syncedCollections.append(record)
        }
    }

    func deleteCollection(id: String, userId _: String) async throws {
        try throwIfNeeded()
        syncedCollections.removeAll { $0.id == id }
        deletedCollectionIds.append(id)
    }

    func syncTag(_ record: TagRecord, userId _: String) async throws {
        try throwIfNeeded()
        if let index = syncedTags.firstIndex(where: { $0.id == record.id }) {
            syncedTags[index] = record
        } else {
            syncedTags.append(record)
        }
    }

    func deleteTag(id: String, userId _: String) async throws {
        try throwIfNeeded()
        syncedTags.removeAll { $0.id == id }
        deletedTagIds.append(id)
    }

    private func throwIfNeeded() throws {
        if shouldFailSync {
            throw MetadataServiceError.syncFailed
        }
    }
}

enum MetadataServiceError: Error {
    case syncFailed
    case missingUserId
}

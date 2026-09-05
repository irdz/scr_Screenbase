//
//  MetadataManager.swift
//  Screenbase
//

import Foundation
import Observation

@MainActor
@Observable
final class MetadataManager {
    private let local: any LocalMetadataStore
    private let remote: any MetadataService

    private(set) var screenshots: [ScreenshotRecord] = []
    private(set) var collections: [CollectionRecord] = []
    private(set) var tags: [TagRecord] = []
    private(set) var userId: String?

    init(local: any LocalMetadataStore, remote: any MetadataService) {
        self.local = local
        self.remote = remote
        apply(local.load())
    }

    /// Scopes Firestore writes to the signed-in anonymous user.
    func configure(userId: String?) {
        self.userId = userId
    }

    // MARK: - Screenshots

    func upsertScreenshot(_ record: ScreenshotRecord) async throws {
        var next = record
        next.updatedAt = Date()
        if let index = screenshots.firstIndex(where: { $0.id == next.id }) {
            screenshots[index] = next
        } else {
            screenshots.append(next)
        }
        try persistLocal()
        await syncRemote { [remote] in
            try await remote.syncScreenshot(next, userId: $0)
        }
    }

    func updateAnnotation(screenshotId: String, text: String?) async throws {
        guard let index = screenshots.firstIndex(where: { $0.id == screenshotId }) else { return }
        screenshots[index].annotationText = text
        screenshots[index].updatedAt = Date()
        let updated = screenshots[index]
        try persistLocal()
        await syncRemote { [remote] in
            try await remote.syncScreenshot(updated, userId: $0)
        }
    }

    func deleteScreenshot(id: String) async throws {
        screenshots.removeAll { $0.id == id }
        try persistLocal()
        await syncRemote { [remote] in
            try await remote.deleteScreenshot(id: id, userId: $0)
        }
    }

    // MARK: - Collections

    @discardableResult
    func createCollection(name: String) async throws -> CollectionRecord {
        let trimmed = Self.trimmedName(name)
        guard !trimmed.isEmpty else { throw MetadataManagerError.invalidName }
        let record = CollectionRecord(name: trimmed)
        collections.append(record)
        try persistLocal()
        await syncRemote { [remote] in
            try await remote.syncCollection(record, userId: $0)
        }
        return record
    }

    func renameCollection(id: String, name: String) async throws {
        let trimmed = Self.trimmedName(name)
        guard !trimmed.isEmpty else { throw MetadataManagerError.invalidName }
        guard let index = collections.firstIndex(where: { $0.id == id }) else { return }
        collections[index].name = trimmed
        collections[index].updatedAt = Date()
        let updated = collections[index]
        try persistLocal()
        await syncRemote { [remote] in
            try await remote.syncCollection(updated, userId: $0)
        }
    }

    func deleteCollection(id: String) async throws {
        collections.removeAll { $0.id == id }
        for index in screenshots.indices {
            screenshots[index].collectionIds.removeAll { $0 == id }
            screenshots[index].updatedAt = Date()
        }
        try persistLocal()
        await syncRemote { [remote] userId in
            try await remote.deleteCollection(id: id, userId: userId)
            for screenshot in screenshots {
                try await remote.syncScreenshot(screenshot, userId: userId)
            }
        }
    }

    func assignCollection(_ collectionId: String, toScreenshot screenshotId: String) async throws {
        try await assignCollections([collectionId], toScreenshots: [screenshotId])
    }

    func assignCollections(_ collectionIds: [String], toScreenshots screenshotIds: [String]) async throws {
        let validCollectionIds = collectionIds.filter { id in
            collections.contains(where: { $0.id == id })
        }
        guard !validCollectionIds.isEmpty, !screenshotIds.isEmpty else { return }

        var changed: [ScreenshotRecord] = []
        for screenshotId in screenshotIds {
            guard let index = screenshots.firstIndex(where: { $0.id == screenshotId }) else { continue }
            var didChange = false
            for collectionId in validCollectionIds where !screenshots[index].collectionIds.contains(collectionId) {
                screenshots[index].collectionIds.append(collectionId)
                didChange = true
            }
            guard didChange else { continue }
            screenshots[index].updatedAt = Date()
            changed.append(screenshots[index])
        }

        guard !changed.isEmpty else { return }
        try persistLocal()
        await syncRemote { [remote] userId in
            for screenshot in changed {
                try await remote.syncScreenshot(screenshot, userId: userId)
            }
        }
    }

    func removeCollection(_ collectionId: String, fromScreenshot screenshotId: String) async throws {
        guard let index = screenshots.firstIndex(where: { $0.id == screenshotId }) else { return }
        screenshots[index].collectionIds.removeAll { $0 == collectionId }
        screenshots[index].updatedAt = Date()
        let updated = screenshots[index]
        try persistLocal()
        await syncRemote { [remote] in
            try await remote.syncScreenshot(updated, userId: $0)
        }
    }

    // MARK: - Tags

    @discardableResult
    func createTag(name: String) async throws -> TagRecord {
        let trimmed = Self.trimmedName(name)
        guard !trimmed.isEmpty else { throw MetadataManagerError.invalidName }
        let record = TagRecord(name: trimmed)
        tags.append(record)
        try persistLocal()
        await syncRemote { [remote] in
            try await remote.syncTag(record, userId: $0)
        }
        return record
    }

    func renameTag(id: String, name: String) async throws {
        let trimmed = Self.trimmedName(name)
        guard !trimmed.isEmpty else { throw MetadataManagerError.invalidName }
        guard let index = tags.firstIndex(where: { $0.id == id }) else { return }
        tags[index].name = trimmed
        tags[index].updatedAt = Date()
        let updated = tags[index]
        try persistLocal()
        await syncRemote { [remote] in
            try await remote.syncTag(updated, userId: $0)
        }
    }

    func deleteTag(id: String) async throws {
        tags.removeAll { $0.id == id }
        for index in screenshots.indices {
            screenshots[index].tagIds.removeAll { $0 == id }
            screenshots[index].updatedAt = Date()
        }
        try persistLocal()
        await syncRemote { [remote] userId in
            try await remote.deleteTag(id: id, userId: userId)
            for screenshot in screenshots {
                try await remote.syncScreenshot(screenshot, userId: userId)
            }
        }
    }

    func assignTag(_ tagId: String, toScreenshot screenshotId: String) async throws {
        try await assignTags([tagId], toScreenshots: [screenshotId])
    }

    func assignTags(_ tagIds: [String], toScreenshots screenshotIds: [String]) async throws {
        let validTagIds = tagIds.filter { id in
            tags.contains(where: { $0.id == id })
        }
        guard !validTagIds.isEmpty, !screenshotIds.isEmpty else { return }

        var changed: [ScreenshotRecord] = []
        for screenshotId in screenshotIds {
            guard let index = screenshots.firstIndex(where: { $0.id == screenshotId }) else { continue }
            var didChange = false
            for tagId in validTagIds where !screenshots[index].tagIds.contains(tagId) {
                screenshots[index].tagIds.append(tagId)
                didChange = true
            }
            guard didChange else { continue }
            screenshots[index].updatedAt = Date()
            changed.append(screenshots[index])
        }

        guard !changed.isEmpty else { return }
        try persistLocal()
        await syncRemote { [remote] userId in
            for screenshot in changed {
                try await remote.syncScreenshot(screenshot, userId: userId)
            }
        }
    }

    func removeTag(_ tagId: String, fromScreenshot screenshotId: String) async throws {
        guard let index = screenshots.firstIndex(where: { $0.id == screenshotId }) else { return }
        screenshots[index].tagIds.removeAll { $0 == tagId }
        screenshots[index].updatedAt = Date()
        let updated = screenshots[index]
        try persistLocal()
        await syncRemote { [remote] in
            try await remote.syncScreenshot(updated, userId: $0)
        }
    }

    private static func trimmedName(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Queries (Library / Search)

    func screenshots(inCollection collectionId: String) -> [ScreenshotRecord] {
        screenshots.filter { $0.collectionIds.contains(collectionId) }
    }

    func screenshots(withTag tagId: String) -> [ScreenshotRecord] {
        screenshots.filter { $0.tagIds.contains(tagId) }
    }

    func screenshotsMatchingAnnotation(query: String) -> [ScreenshotRecord] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return screenshots }
        return screenshots.filter {
            ($0.annotationText ?? "").localizedCaseInsensitiveContains(trimmed)
        }
    }

    // MARK: - Persistence helpers

    private func apply(_ snapshot: MetadataStoreSnapshot) {
        screenshots = snapshot.screenshots.map { record in
            guard record.id.contains("/") else { return record }
            var fixed = record
            fixed.id = FirestoreDocumentID.fromAssetLocalIdentifier(record.assetLocalIdentifier)
            return fixed
        }
        collections = snapshot.collections
        tags = snapshot.tags
    }

    private func persistLocal() throws {
        try local.save(
            MetadataStoreSnapshot(
                screenshots: screenshots,
                collections: collections,
                tags: tags
            )
        )
    }

    /// Best-effort remote sync — local writes already succeeded and must not roll back.
    private func syncRemote(_ work: @MainActor (String) async throws -> Void) async {
        guard let userId else { return }
        do {
            try await work(userId)
        } catch {
            // Offline / Firestore errors must not block core local functionality.
        }
    }
}

extension MetadataManager: ScreenshotIndexing {
    var indexedAssetIdentifiers: Set<String> {
        Set(screenshots.map(\.assetLocalIdentifier))
    }

    func indexNewScreenshots(_ discovered: [DiscoveredScreenshot]) async throws {
        for item in discovered where !indexedAssetIdentifiers.contains(item.assetLocalIdentifier) {
            try await upsertScreenshot(ScreenshotRecord(discovered: item))
        }
    }
}

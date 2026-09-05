//
//  MetadataManager_Tests.swift
//  ScreenbaseTests
//

import Foundation
@testable import Screenbase
import Testing

@Suite("MetadataManager Tests")
struct MetadataManager_Tests {
    @Test("Upsert screenshot persists locally and syncs remotely")
    @MainActor
    func upsertScreenshotPersistsAndSyncs() async throws {
        // Given
        let local = InMemoryLocalMetadataStore()
        let remote = MockMetadataService()
        let sut = MetadataManager(local: local, remote: remote)
        sut.configure(userId: "user_1")

        // When
        try await sut.upsertScreenshot(.mock)

        // Then
        #expect(sut.screenshots.count == 1)
        #expect(local.load().screenshots.count == 1)
        #expect(remote.syncedScreenshots.count == 1)
        #expect(sut.indexedAssetIdentifiers.contains(ScreenshotRecord.mock.assetLocalIdentifier))
    }

    @Test("Index new screenshots skips already indexed assets")
    @MainActor
    func indexNewScreenshotsSkipsDuplicates() async throws {
        // Given
        let sut = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        try await sut.indexNewScreenshots(DiscoveredScreenshot.mocks)

        // When
        try await sut.indexNewScreenshots(DiscoveredScreenshot.mocks)

        // Then
        #expect(sut.screenshots.count == 3)
    }

    @Test("Create collection and assign to screenshot")
    @MainActor
    func createCollectionAndAssign() async throws {
        // Given
        let remote = MockMetadataService()
        let sut = MetadataManager(local: InMemoryLocalMetadataStore(), remote: remote)
        sut.configure(userId: "user_1")
        try await sut.upsertScreenshot(.mock)

        // When
        let collection = try await sut.createCollection(name: "Bugs")
        try await sut.assignCollection(collection.id, toScreenshot: ScreenshotRecord.mock.id)

        // Then
        let screenshot = try #require(sut.screenshots.first)
        #expect(screenshot.collectionIds.contains(collection.id))
        #expect(sut.screenshots(inCollection: collection.id).count == 1)
        #expect(remote.syncedCollections.count == 1)
    }

    @Test("Create tag and assign to screenshot")
    @MainActor
    func createTagAndAssign() async throws {
        // Given
        let sut = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        sut.configure(userId: "user_1")
        try await sut.upsertScreenshot(.mock)

        // When
        let tag = try await sut.createTag(name: "ios")
        try await sut.assignTag(tag.id, toScreenshot: ScreenshotRecord.mock.id)

        // Then
        let screenshot = try #require(sut.screenshots.first)
        #expect(screenshot.tagIds.contains(tag.id))
        #expect(sut.screenshots(withTag: tag.id).count == 1)
    }

    @Test("Remove collection clears associations")
    @MainActor
    func deleteCollectionClearsAssociations() async throws {
        // Given
        let sut = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        let screenshot = ScreenshotRecord(
            id: "SHOT/CLEAN",
            assetLocalIdentifier: "SHOT/CLEAN",
            collectionIds: [],
            tagIds: []
        )
        try await sut.upsertScreenshot(screenshot)
        let collection = try await sut.createCollection(name: "Temp")
        try await sut.assignCollection(collection.id, toScreenshot: screenshot.id)

        // When
        try await sut.deleteCollection(id: collection.id)

        // Then
        #expect(sut.collections.isEmpty)
        #expect(sut.screenshots.first?.collectionIds.isEmpty == true)
    }

    @Test("Rename collection and tag update names")
    @MainActor
    func renameCollectionAndTag() async throws {
        // Given
        let remote = MockMetadataService()
        let sut = MetadataManager(local: InMemoryLocalMetadataStore(), remote: remote)
        sut.configure(userId: "user_1")
        let collection = try await sut.createCollection(name: "Old Collection")
        let tag = try await sut.createTag(name: "old-tag")

        // When
        try await sut.renameCollection(id: collection.id, name: "  New Collection ")
        try await sut.renameTag(id: tag.id, name: "new-tag")

        // Then
        #expect(sut.collections.first?.name == "New Collection")
        #expect(sut.tags.first?.name == "new-tag")
        #expect(remote.syncedCollections.last?.name == "New Collection")
        #expect(remote.syncedTags.last?.name == "new-tag")
    }

    @Test("Empty names are rejected")
    @MainActor
    func emptyNamesAreRejected() async {
        // Given
        let sut = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())

        // When / Then
        await #expect(throws: MetadataManagerError.invalidName) {
            _ = try await sut.createCollection(name: "   ")
        }
        await #expect(throws: MetadataManagerError.invalidName) {
            _ = try await sut.createTag(name: "")
        }
    }

    @Test("Bulk assign collections and tags to multiple screenshots")
    @MainActor
    func bulkAssignToMultipleScreenshots() async throws {
        // Given
        let sut = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        try await sut.upsertScreenshot(ScreenshotRecord(id: "a", assetLocalIdentifier: "a"))
        try await sut.upsertScreenshot(ScreenshotRecord(id: "b", assetLocalIdentifier: "b"))
        let collection = try await sut.createCollection(name: "Bugs")
        let tag = try await sut.createTag(name: "ios")

        // When
        try await sut.assignCollections([collection.id], toScreenshots: ["a", "b"])
        try await sut.assignTags([tag.id], toScreenshots: ["a", "b"])

        // Then
        #expect(sut.screenshots.allSatisfy { $0.collectionIds.contains(collection.id) })
        #expect(sut.screenshots.allSatisfy { $0.tagIds.contains(tag.id) })
        #expect(sut.screenshots(inCollection: collection.id).count == 2)
    }

    @Test("Delete tag clears associations without deleting screenshots")
    @MainActor
    func deleteTagClearsAssociations() async throws {
        // Given
        let sut = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        let screenshot = ScreenshotRecord(
            id: "shot-tag",
            assetLocalIdentifier: "shot-tag",
            collectionIds: [],
            tagIds: []
        )
        try await sut.upsertScreenshot(screenshot)
        let tag = try await sut.createTag(name: "temp")
        try await sut.assignTag(tag.id, toScreenshot: screenshot.id)

        // When
        try await sut.deleteTag(id: tag.id)

        // Then
        #expect(sut.tags.isEmpty)
        #expect(sut.screenshots.count == 1)
        #expect(sut.screenshots.first?.tagIds.isEmpty == true)
    }

    @Test("Annotation search matches case-insensitively")
    @MainActor
    func annotationSearchMatches() async throws {
        // Given
        let sut = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        var record = ScreenshotRecord.mock
        record.annotationText = "Checkout crash"
        try await sut.upsertScreenshot(record)

        // When / Then
        #expect(sut.screenshotsMatchingAnnotation(query: "checkout").count == 1)
        #expect(sut.screenshotsMatchingAnnotation(query: "missing").isEmpty)
    }

    @Test("Remote sync failure does not roll back local write")
    @MainActor
    func remoteFailureKeepsLocalWrite() async throws {
        // Given
        let local = InMemoryLocalMetadataStore()
        let remote = MockMetadataService()
        remote.shouldFailSync = true
        let sut = MetadataManager(local: local, remote: remote)
        sut.configure(userId: "user_1")

        // When
        try await sut.upsertScreenshot(.mock)

        // Then
        #expect(sut.screenshots.count == 1)
        #expect(local.load().screenshots.count == 1)
        #expect(remote.syncedScreenshots.isEmpty)
    }

    @Test("File store survives manager recreate")
    @MainActor
    func fileStoreSurvivesRelaunch() async throws {
        // Given
        let fileName = "metadata_store_test_\(UUID().uuidString).json"
        let store = FileLocalMetadataStore(fileName: fileName)
        let first = MetadataManager(local: store, remote: MockMetadataService())
        try await first.upsertScreenshot(.mock)
        try await first.createTag(name: "persist")

        // When
        let second = MetadataManager(local: FileLocalMetadataStore(fileName: fileName), remote: MockMetadataService())

        // Then
        #expect(second.screenshots.count == 1)
        #expect(second.tags.count == 1)
    }
}

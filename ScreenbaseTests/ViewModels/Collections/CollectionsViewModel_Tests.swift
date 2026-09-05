//
//  CollectionsViewModel_Tests.swift
//  ScreenbaseTests
//

import Foundation
@testable import Screenbase
import Testing

@Suite("CollectionsViewModel Tests")
struct CollectionsViewModel_Tests {
    @Test("Create collection via name editor")
    @MainActor
    func createCollectionViaNameEditor() async {
        // Given
        let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        let sut = CollectionsViewModel(metadataManager: metadata)
        sut.presentCreateCollection()
        sut.nameDraft = "Bugs"

        // When
        await sut.saveNameEditor()

        // Then
        #expect(metadata.collections.map(\.name) == ["Bugs"])
        #expect(sut.nameEditorMode == nil)
    }

    @Test("Rename and delete tag")
    @MainActor
    func renameAndDeleteTag() async throws {
        // Given
        let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        let tag = try await metadata.createTag(name: "old")
        let sut = CollectionsViewModel(metadataManager: metadata)

        // When
        sut.presentRenameTag(tag)
        sut.nameDraft = "new"
        await sut.saveNameEditor()

        // Then
        #expect(metadata.tags.first?.name == "new")

        // When
        try sut.confirmDeleteTag(#require(metadata.tags.first))
        await sut.deletePendingTag()

        // Then
        #expect(metadata.tags.isEmpty)
    }

    @Test("Latest screenshot prefers most recently updated membership")
    @MainActor
    func latestScreenshotPrefersMostRecentlyUpdated() async throws {
        // Given
        let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        let collection = try await metadata.createCollection(name: "Bugs")
        try await metadata.upsertScreenshot(
            ScreenshotRecord(
                id: "older",
                assetLocalIdentifier: "older",
                updatedAt: Date(timeIntervalSince1970: 1000)
            )
        )
        try await metadata.upsertScreenshot(
            ScreenshotRecord(
                id: "newer",
                assetLocalIdentifier: "newer",
                updatedAt: Date(timeIntervalSince1970: 2000)
            )
        )
        try await metadata.assignCollection(collection.id, toScreenshot: "older")
        try await metadata.assignCollection(collection.id, toScreenshot: "newer")
        // Re-stamp older as more recently updated so it wins as "latest added".
        var older = try #require(metadata.screenshots.first(where: { $0.id == "older" }))
        older.updatedAt = Date(timeIntervalSince1970: 3000)
        try await metadata.upsertScreenshot(older)
        let sut = CollectionsViewModel(metadataManager: metadata)

        // When / Then
        #expect(sut.latestScreenshot(inCollection: collection.id)?.id == "older")
        #expect(sut.screenshotCount(for: collection.id) == 2)
    }
}

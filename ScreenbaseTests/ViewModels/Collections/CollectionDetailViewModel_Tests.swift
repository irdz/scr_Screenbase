//
//  CollectionDetailViewModel_Tests.swift
//  ScreenbaseTests
//

import Foundation
@testable import Screenbase
import Testing

@Suite("CollectionDetailViewModel Tests")
struct CollectionDetailViewModel_Tests {
    @Test("Screenshots filter to the collection and sort newest first")
    @MainActor
    func screenshotsFilterAndSortNewestFirst() async throws {
        // Given
        let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        let collection = try await metadata.createCollection(name: "Bugs")
        try await metadata.upsertScreenshot(
            ScreenshotRecord(
                id: "old",
                assetLocalIdentifier: "old",
                captureDate: Date(timeIntervalSince1970: 1_000),
                collectionIds: [collection.id]
            )
        )
        try await metadata.upsertScreenshot(
            ScreenshotRecord(
                id: "new",
                assetLocalIdentifier: "new",
                captureDate: Date(timeIntervalSince1970: 2_000),
                collectionIds: [collection.id]
            )
        )
        try await metadata.upsertScreenshot(
            ScreenshotRecord(
                id: "other",
                assetLocalIdentifier: "other",
                captureDate: Date(timeIntervalSince1970: 3_000),
                collectionIds: []
            )
        )
        let sut = CollectionDetailViewModel(collectionId: collection.id, metadataManager: metadata)

        // When / Then
        #expect(sut.screenshots.map(\.id) == ["new", "old"])
        #expect(sut.contentState == .populated)
        #expect(sut.title == "Bugs")
    }

    @Test("Empty collection reports empty content state")
    @MainActor
    func emptyCollectionReportsEmptyState() async throws {
        // Given
        let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        let collection = try await metadata.createCollection(name: "Empty")
        let sut = CollectionDetailViewModel(collectionId: collection.id, metadataManager: metadata)

        // When / Then
        #expect(sut.contentState == .empty)
        #expect(sut.screenshots.isEmpty)
    }

    @Test("Tile tap sets detail screenshot id")
    @MainActor
    func tileTapSetsDetailScreenshotId() async throws {
        // Given
        let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        let collection = try await metadata.createCollection(name: "Bugs")
        let sut = CollectionDetailViewModel(collectionId: collection.id, metadataManager: metadata)

        // When
        sut.handleTileTap(screenshotId: "shot")

        // Then
        #expect(sut.detailScreenshotId == "shot")
        sut.clearDetail()
        #expect(sut.detailScreenshotId == nil)
    }
}

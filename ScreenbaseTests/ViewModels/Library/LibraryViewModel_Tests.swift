//
//  LibraryViewModel_Tests.swift
//  ScreenbaseTests
//

import Foundation
@testable import Screenbase
import Testing

@Suite("LibraryViewModel Tests")
struct LibraryViewModel_Tests {
    @Test("Filtered screenshots sort newest first")
    @MainActor
    func filteredScreenshotsSortNewestFirst() async throws {
        // Given
        let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        let older = ScreenshotRecord(
            id: "old",
            assetLocalIdentifier: "old",
            captureDate: Date(timeIntervalSince1970: 1000)
        )
        let newer = ScreenshotRecord(
            id: "new",
            assetLocalIdentifier: "new",
            captureDate: Date(timeIntervalSince1970: 2000)
        )
        try await metadata.upsertScreenshot(older)
        try await metadata.upsertScreenshot(newer)
        let sut = LibraryViewModel(
            metadataManager: metadata,
            screenshotManager: ScreenshotManager(service: MockScreenshotService(screenshots: []), index: metadata)
        )

        // When / Then
        #expect(sut.filteredScreenshots.map(\.id) == ["new", "old"])
        #expect(sut.contentState == .populated)
    }

    @Test("Collections filter only includes assigned screenshots")
    @MainActor
    func collectionsFilterIncludesAssignedOnly() async throws {
        // Given
        let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        try await metadata.upsertScreenshot(
            ScreenshotRecord(id: "a", assetLocalIdentifier: "a", collectionIds: [])
        )
        try await metadata.upsertScreenshot(
            ScreenshotRecord(id: "b", assetLocalIdentifier: "b", collectionIds: ["col"])
        )
        let sut = LibraryViewModel(
            metadataManager: metadata,
            screenshotManager: ScreenshotManager(service: MockScreenshotService(screenshots: []), index: metadata)
        )

        // When
        sut.selectFilter(.collections)

        // Then
        #expect(sut.filteredScreenshots.map(\.id) == ["b"])
    }

    @Test("Select mode toggles tile selection instead of opening detail")
    @MainActor
    func selectModeTogglesSelection() async throws {
        // Given
        let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        try await metadata.upsertScreenshot(.mock)
        let sut = LibraryViewModel(
            metadataManager: metadata,
            screenshotManager: ScreenshotManager(service: MockScreenshotService(screenshots: []), index: metadata)
        )

        // When
        sut.toggleSelecting()
        sut.handleTileTap(screenshotId: ScreenshotRecord.mock.id)

        // Then
        #expect(sut.isSelected(ScreenshotRecord.mock.id))
        #expect(sut.detailScreenshotId == nil)

        // When
        sut.toggleSelecting()

        // Then
        #expect(sut.selectedScreenshotIds.isEmpty)
        #expect(sut.isSelecting == false)
    }

    @Test("Tap outside select mode opens detail")
    @MainActor
    func tapOpensDetailOutsideSelectMode() async throws {
        // Given
        let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        try await metadata.upsertScreenshot(.mock)
        let sut = LibraryViewModel(
            metadataManager: metadata,
            screenshotManager: ScreenshotManager(service: MockScreenshotService(screenshots: []), index: metadata)
        )

        // When
        sut.handleTileTap(screenshotId: ScreenshotRecord.mock.id)

        // Then
        #expect(sut.detailScreenshotId == ScreenshotRecord.mock.id)
    }

    @Test("Empty library reports empty content state")
    @MainActor
    func emptyLibraryReportsEmptyState() {
        // Given
        let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        let sut = LibraryViewModel(
            metadataManager: metadata,
            screenshotManager: ScreenshotManager(
                service: MockScreenshotService(screenshots: []),
                index: metadata
            )
        )

        // Then
        #expect(sut.contentState == .empty)
        #expect(sut.filteredScreenshots.isEmpty)
    }
}

//
//  ScreenshotDetailViewModel_Tests.swift
//  ScreenbaseTests
//

import Foundation
@testable import Screenbase
import Testing
import UIKit

@Suite("ScreenshotDetailViewModel Tests")
struct ScreenshotDetailViewModel_Tests {
    @Test("Missing Photos asset surfaces missing image state")
    @MainActor
    func missingAssetSurfacesMissingState() async throws {
        // Given
        let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        try await metadata.upsertScreenshot(.mock)
        let photos = PhotosManager(service: MockPhotosService(
            status: .authorized,
            missingAssetIdentifiers: [ScreenshotRecord.mock.assetLocalIdentifier]
        ))
        let sut = ScreenshotDetailViewModel(
            screenshotId: ScreenshotRecord.mock.id,
            metadataManager: metadata,
            photosManager: photos,
            imageTargetSize: CGSize(width: 100, height: 100)
        )

        // When
        await sut.loadImageIfNeeded()

        // Then
        #expect(sut.imageState == .missing)
        #expect(sut.image == nil)
        #expect(sut.canShare == false)
        #expect(sut.screenshot?.annotationText == "Login flow")
    }

    @Test("Saving annotation updates metadata")
    @MainActor
    func savingAnnotationUpdatesMetadata() async throws {
        // Given
        let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        try await metadata.upsertScreenshot(.mock)
        let sut = ScreenshotDetailViewModel(
            screenshotId: ScreenshotRecord.mock.id,
            metadataManager: metadata,
            photosManager: PhotosManager(service: MockPhotosService(status: .authorized)),
            imageTargetSize: CGSize(width: 100, height: 100)
        )
        sut.presentAnnotationEditor()
        sut.annotationDraft = "Updated note"

        // When
        await sut.saveAnnotation()

        // Then
        #expect(metadata.screenshots.first?.annotationText == "Updated note")
        #expect(sut.isAnnotationEditorPresented == false)
    }

    @Test("Applying memberships replaces collections and tags")
    @MainActor
    func applyingMembershipsReplacesSets() async throws {
        // Given
        let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
        let keep = try await metadata.createCollection(name: "Keep")
        let drop = try await metadata.createCollection(name: "Drop")
        let tag = try await metadata.createTag(name: "bug")
        try await metadata.upsertScreenshot(
            ScreenshotRecord(
                id: "shot",
                assetLocalIdentifier: "shot",
                collectionIds: [drop.id],
                tagIds: []
            )
        )
        let sut = ScreenshotDetailViewModel(
            screenshotId: "shot",
            metadataManager: metadata,
            photosManager: PhotosManager(service: MockPhotosService(status: .authorized)),
            imageTargetSize: CGSize(width: 100, height: 100)
        )
        sut.presentMembershipSheet()
        sut.toggleMembershipCollection(drop.id)
        sut.toggleMembershipCollection(keep.id)
        sut.toggleMembershipTag(tag.id)

        // When
        await sut.applyMemberships()

        // Then
        let record = try #require(metadata.screenshots.first)
        #expect(Set(record.collectionIds) == [keep.id])
        #expect(Set(record.tagIds) == [tag.id])
        #expect(sut.isMembershipSheetPresented == false)
    }
}

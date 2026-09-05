//
//  ScreenshotDetailViewModel.swift
//  Screenbase
//

import Foundation
import Observation
import UIKit

@MainActor
@Observable
final class ScreenshotDetailViewModel {
    enum ImageState: Equatable {
        case loading
        case loaded
        case missing
    }

    let screenshotId: String

    var image: UIImage?
    var imageState: ImageState = .loading
    var isAnnotationEditorPresented = false
    var annotationDraft = ""
    var isMembershipSheetPresented = false
    var selectedCollectionIds: Set<String> = []
    var selectedTagIds: Set<String> = []
    var membershipNameEditorMode: MembershipNameEditorMode?
    var membershipNameDraft = ""
    var isSharePresented = false

    enum MembershipNameEditorMode: Equatable {
        case collection
        case tag
    }

    private let metadataManager: MetadataManager
    private let photosManager: PhotosManager
    private let imageTargetSize: CGSize

    init(
        screenshotId: String,
        metadataManager: MetadataManager,
        photosManager: PhotosManager,
        imageTargetSize: CGSize
    ) {
        self.screenshotId = screenshotId
        self.metadataManager = metadataManager
        self.photosManager = photosManager
        self.imageTargetSize = imageTargetSize
    }

    var screenshot: ScreenshotRecord? {
        metadataManager.screenshots.first { $0.id == screenshotId }
    }

    var assignedCollections: [CollectionRecord] {
        guard let screenshot else { return [] }
        return metadataManager.collections
            .filter { screenshot.collectionIds.contains($0.id) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var assignedTags: [TagRecord] {
        guard let screenshot else { return [] }
        return metadataManager.tags
            .filter { screenshot.tagIds.contains($0.id) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var allCollections: [CollectionRecord] {
        metadataManager.collections.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    var allTags: [TagRecord] {
        metadataManager.tags.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    var annotationDisplayText: String {
        let text = screenshot?.annotationText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return text.isEmpty ? "Add a note…" : text
    }

    var hasAnnotation: Bool {
        let text = screenshot?.annotationText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return !text.isEmpty
    }

    var canShare: Bool {
        image != nil
    }

    var isMembershipNameEditorPresented: Bool {
        get { membershipNameEditorMode != nil }
        set {
            if !newValue {
                membershipNameEditorMode = nil
                membershipNameDraft = ""
            }
        }
    }

    var membershipNameEditorTitle: String {
        switch membershipNameEditorMode {
        case .collection: "New Collection"
        case .tag: "New Tag"
        case nil: ""
        }
    }

    var canSaveMembershipName: Bool {
        !membershipNameDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func loadImageIfNeeded() async {
        guard imageState == .loading || (imageState == .loaded && image == nil) else { return }
        guard let assetId = screenshot?.assetLocalIdentifier else {
            imageState = .missing
            return
        }
        imageState = .loading
        let loaded = await photosManager.fullImage(
            forAssetLocalIdentifier: assetId,
            targetSize: imageTargetSize
        )
        image = loaded
        imageState = loaded == nil ? .missing : .loaded
    }

    func presentAnnotationEditor() {
        annotationDraft = screenshot?.annotationText ?? ""
        isAnnotationEditorPresented = true
    }

    func saveAnnotation() async {
        let trimmed = annotationDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        try? await metadataManager.updateAnnotation(
            screenshotId: screenshotId,
            text: trimmed.isEmpty ? nil : trimmed
        )
        isAnnotationEditorPresented = false
    }

    func presentMembershipSheet() {
        selectedCollectionIds = Set(screenshot?.collectionIds ?? [])
        selectedTagIds = Set(screenshot?.tagIds ?? [])
        membershipNameEditorMode = nil
        membershipNameDraft = ""
        isMembershipSheetPresented = true
    }

    func toggleMembershipCollection(_ id: String) {
        if selectedCollectionIds.contains(id) {
            selectedCollectionIds.remove(id)
        } else {
            selectedCollectionIds.insert(id)
        }
    }

    func toggleMembershipTag(_ id: String) {
        if selectedTagIds.contains(id) {
            selectedTagIds.remove(id)
        } else {
            selectedTagIds.insert(id)
        }
    }

    func presentCreateMembershipCollection() {
        membershipNameDraft = ""
        membershipNameEditorMode = .collection
    }

    func presentCreateMembershipTag() {
        membershipNameDraft = ""
        membershipNameEditorMode = .tag
    }

    func saveMembershipNameEditor() async {
        let draft = membershipNameDraft
        guard let mode = membershipNameEditorMode else { return }
        do {
            switch mode {
            case .collection:
                let collection = try await metadataManager.createCollection(name: draft)
                selectedCollectionIds.insert(collection.id)
            case .tag:
                let tag = try await metadataManager.createTag(name: draft)
                selectedTagIds.insert(tag.id)
            }
            membershipNameEditorMode = nil
            membershipNameDraft = ""
        } catch {
            // Keep editor open for empty/invalid names.
        }
    }

    func applyMemberships() async {
        try? await metadataManager.setCollections(Array(selectedCollectionIds), forScreenshot: screenshotId)
        try? await metadataManager.setTags(Array(selectedTagIds), forScreenshot: screenshotId)
        isMembershipSheetPresented = false
    }

    func presentShare() {
        guard canShare else { return }
        isSharePresented = true
    }
}

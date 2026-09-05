//
//  CollectionsViewModel.swift
//  Screenbase
//

import Foundation
import Observation

@MainActor
@Observable
final class CollectionsViewModel {
    enum NameEditorMode: Equatable {
        case createCollection
        case renameCollection(id: String)
        case createTag
        case renameTag(id: String)
    }

    var nameEditorMode: NameEditorMode?
    var nameDraft = ""
    var pendingDeleteCollectionId: String?
    var pendingDeleteTagId: String?

    private let metadataManager: MetadataManager

    init(metadataManager: MetadataManager) {
        self.metadataManager = metadataManager
    }

    var collections: [CollectionRecord] {
        metadataManager.collections.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    var tags: [TagRecord] {
        metadataManager.tags.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    var isNameEditorPresented: Bool {
        get { nameEditorMode != nil }
        set {
            if !newValue {
                nameEditorMode = nil
                nameDraft = ""
            }
        }
    }

    var nameEditorTitle: String {
        switch nameEditorMode {
        case .createCollection: "New Collection"
        case .renameCollection: "Rename Collection"
        case .createTag: "New Tag"
        case .renameTag: "Rename Tag"
        case nil: ""
        }
    }

    var nameEditorSaveTitle: String {
        switch nameEditorMode {
        case .createCollection, .createTag: "Create"
        case .renameCollection, .renameTag: "Save"
        case nil: "Save"
        }
    }

    var canSaveName: Bool {
        !nameDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func screenshotCount(for collectionId: String) -> Int {
        metadataManager.screenshots(inCollection: collectionId).count
    }

    func screenshotCount(forTag tagId: String) -> Int {
        metadataManager.screenshots(withTag: tagId).count
    }

    func presentCreateCollection() {
        nameDraft = ""
        nameEditorMode = .createCollection
    }

    func presentRenameCollection(_ collection: CollectionRecord) {
        nameDraft = collection.name
        nameEditorMode = .renameCollection(id: collection.id)
    }

    func presentCreateTag() {
        nameDraft = ""
        nameEditorMode = .createTag
    }

    func presentRenameTag(_ tag: TagRecord) {
        nameDraft = tag.name
        nameEditorMode = .renameTag(id: tag.id)
    }

    func confirmDeleteCollection(_ collection: CollectionRecord) {
        pendingDeleteCollectionId = collection.id
    }

    func confirmDeleteTag(_ tag: TagRecord) {
        pendingDeleteTagId = tag.id
    }

    func saveNameEditor() async {
        let draft = nameDraft
        guard let mode = nameEditorMode else { return }
        do {
            switch mode {
            case .createCollection:
                _ = try await metadataManager.createCollection(name: draft)
            case .renameCollection(let id):
                try await metadataManager.renameCollection(id: id, name: draft)
            case .createTag:
                _ = try await metadataManager.createTag(name: draft)
            case .renameTag(let id):
                try await metadataManager.renameTag(id: id, name: draft)
            }
            nameEditorMode = nil
            nameDraft = ""
        } catch {
            // Keep editor open so the user can fix an empty/invalid name.
        }
    }

    func deletePendingCollection() async {
        guard let id = pendingDeleteCollectionId else { return }
        pendingDeleteCollectionId = nil
        try? await metadataManager.deleteCollection(id: id)
    }

    func deletePendingTag() async {
        guard let id = pendingDeleteTagId else { return }
        pendingDeleteTagId = nil
        try? await metadataManager.deleteTag(id: id)
    }
}

//
//  InMemoryLocalMetadataStore.swift
//  Screenbase
//

import Foundation

@MainActor
final class InMemoryLocalMetadataStore: LocalMetadataStore {
    private var snapshot: MetadataStoreSnapshot

    init(snapshot: MetadataStoreSnapshot = .empty) {
        self.snapshot = snapshot
    }

    func load() -> MetadataStoreSnapshot {
        snapshot
    }

    func save(_ snapshot: MetadataStoreSnapshot) throws {
        self.snapshot = snapshot
    }
}

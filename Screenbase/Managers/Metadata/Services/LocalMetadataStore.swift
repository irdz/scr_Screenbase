//
//  LocalMetadataStore.swift
//  Screenbase
//

import Foundation

@MainActor
protocol LocalMetadataStore {
    func load() -> MetadataStoreSnapshot
    func save(_ snapshot: MetadataStoreSnapshot) throws
}

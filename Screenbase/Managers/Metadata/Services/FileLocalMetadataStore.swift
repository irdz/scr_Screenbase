//
//  FileLocalMetadataStore.swift
//  Screenbase
//

import Foundation

/// Persists metadata as JSON under Application Support so it survives relaunch.
struct FileLocalMetadataStore: LocalMetadataStore {
    private let fileName: String
    private let fileManager: FileManager

    init(fileName: String = "metadata_store.json", fileManager: FileManager = .default) {
        self.fileName = fileName
        self.fileManager = fileManager
    }

    func load() -> MetadataStoreSnapshot {
        guard let url = try? fileURL(),
              let data = try? Data(contentsOf: url),
              let snapshot = try? JSONDecoder().decode(MetadataStoreSnapshot.self, from: data)
        else {
            return .empty
        }
        return snapshot
    }

    func save(_ snapshot: MetadataStoreSnapshot) throws {
        let url = try fileURL()
        let data = try JSONEncoder().encode(snapshot)
        try data.write(to: url, options: .atomic)
    }

    private func directoryURL() throws -> URL {
        let base = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let dir = base.appendingPathComponent("Screenbase", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private func fileURL() throws -> URL {
        try directoryURL().appendingPathComponent(fileName)
    }
}

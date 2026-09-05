//
//  MetadataService.swift
//  Screenbase
//

import Foundation

/// Remote sync boundary for metadata documents (Firestore in production).
@MainActor
protocol MetadataService {
    func syncScreenshot(_ record: ScreenshotRecord, userId: String) async throws
    func deleteScreenshot(id: String, userId: String) async throws

    func syncCollection(_ record: CollectionRecord, userId: String) async throws
    func deleteCollection(id: String, userId: String) async throws

    func syncTag(_ record: TagRecord, userId: String) async throws
    func deleteTag(id: String, userId: String) async throws
}

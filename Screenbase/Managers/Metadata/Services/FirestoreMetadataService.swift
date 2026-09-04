//
//  FirestoreMetadataService.swift
//  Screenbase
//

import FirebaseFirestore
import Foundation

/// Syncs metadata under `users/{userId}/screenshots|collections|tags/{id}`.
struct FirestoreMetadataService: MetadataService {
    private let firestore: Firestore

    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }

    func syncScreenshot(_ record: ScreenshotRecord, userId: String) async throws {
        try screenshots(userId: userId).document(sanitizedDocumentId(record.id)).setData(from: record, merge: true)
    }

    func deleteScreenshot(id: String, userId: String) async throws {
        try await screenshots(userId: userId).document(sanitizedDocumentId(id)).delete()
    }

    func syncCollection(_ record: CollectionRecord, userId: String) async throws {
        try collections(userId: userId).document(sanitizedDocumentId(record.id)).setData(from: record, merge: true)
    }

    func deleteCollection(id: String, userId: String) async throws {
        try await collections(userId: userId).document(sanitizedDocumentId(id)).delete()
    }

    func syncTag(_ record: TagRecord, userId: String) async throws {
        try tags(userId: userId).document(sanitizedDocumentId(record.id)).setData(from: record, merge: true)
    }

    func deleteTag(id: String, userId: String) async throws {
        try await tags(userId: userId).document(sanitizedDocumentId(id)).delete()
    }

    /// Defensive: never let `/` in an id create unintended nested paths under the collection.
    private func sanitizedDocumentId(_ id: String) -> String {
        id.replacingOccurrences(of: "/", with: "__")
    }

    private func screenshots(userId: String) -> CollectionReference {
        userDocument(userId).collection("screenshots")
    }

    private func collections(userId: String) -> CollectionReference {
        userDocument(userId).collection("collections")
    }

    private func tags(userId: String) -> CollectionReference {
        userDocument(userId).collection("tags")
    }

    private func userDocument(_ userId: String) -> DocumentReference {
        firestore.collection("users").document(userId)
    }
}

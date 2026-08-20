//
//  FirebaseRemoteUserServiceLive.swift
//  Screenbase
//

import FirebaseFirestore
import Foundation

/// Writes to Firestore `users/{userId}`. Configure security rules so authenticated users can read/write their own
/// document.
struct FirebaseRemoteUserServiceLive: RemoteUserService {
    private var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }

    func saveUser(user: AppUserProfile) async throws {
        try collection.document(user.userId).setData(from: user, merge: true)
    }

    func markOnboardingCompleted(userId: String) async throws {
        try await collection.document(userId).updateData([
            AppUserProfile.CodingKeys.didCompleteOnboarding.rawValue: true
        ])
    }

    func streamUser(
        userId: String,
        onListenerConfigured: @escaping @Sendable (FirestoreListenerRegistration?) -> Void
    ) -> AsyncThrowingStream<AppUserProfile, Error> {
        AsyncThrowingStream { continuation in
            let registration = collection.document(userId).addSnapshotListener { snapshot, error in
                if let error {
                    continuation.finish(throwing: error)
                    return
                }
                guard let snapshot, snapshot.exists else { return }
                do {
                    let profile = try snapshot.data(as: AppUserProfile.self)
                    continuation.yield(profile)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            onListenerConfigured(registration)
            continuation.onTermination = { @Sendable _ in
                registration.remove()
            }
        }
    }

    func deleteUser(userId: String) async throws {
        try await collection.document(userId).delete()
    }
}

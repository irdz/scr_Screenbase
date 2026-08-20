//
//  MockRemoteUserService.swift
//  Screenbase
//

import Foundation

/// In-memory Firestore stand-in for tests; mirrors writes into ``MockLocalUserPersistenceService``.
final class MockRemoteUserService: RemoteUserService, @unchecked Sendable {
    private weak var localMirror: MockLocalUserPersistenceService?

    init(localMirror: MockLocalUserPersistenceService) {
        self.localMirror = localMirror
    }

    func saveUser(user: AppUserProfile) async throws {
        localMirror?.replace(user)
    }

    func markOnboardingCompleted(userId: String) async throws {
        guard var user = localMirror?.stored else { return }
        guard user.userId == userId else { return }
        user.didCompleteOnboarding = true
        localMirror?.replace(user)
    }

    func streamUser(
        userId: String,
        onListenerConfigured: @escaping @Sendable (FirestoreListenerRegistration?) -> Void
    ) -> AsyncThrowingStream<AppUserProfile, Error> {
        AsyncThrowingStream { continuation in
            onListenerConfigured(nil)
            if let user = self.localMirror?.stored, user.userId == userId {
                continuation.yield(user)
            }
            continuation.finish()
        }
    }

    func deleteUser(userId: String) async throws {
        if localMirror?.stored?.userId == userId {
            localMirror?.replace(nil)
        }
    }
}

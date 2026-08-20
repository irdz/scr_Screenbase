//
//  UserManager.swift
//  Screenbase
//

import FirebaseFirestore
import Foundation
import Observation

@MainActor
@Observable
final class UserManager {
    private let remote: RemoteUserService
    private let local: LocalUserPersistenceService

    private(set) var currentUser: AppUserProfile?
    private var currentUserListener: FirestoreListenerRegistration?

    init(services: UserServices) {
        remote = services.remote
        local = services.local
        currentUser = local.getCurrentUser()
    }

    func login(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) : nil
        let user = AppUserProfile(auth: auth, creationVersion: creationVersion)
        try await remote.saveUser(user: user)
        currentUser = user
        addCurrentUserListener(userId: auth.uid)
    }

    private func addCurrentUserListener(userId: String) {
        currentUserListener?.remove()
        Task { @MainActor in
            do {
                for try await value in remote.streamUser(userId: userId, onListenerConfigured: { reg in
                    Task { @MainActor in
                        self.currentUserListener?.remove()
                        self.currentUserListener = reg
                    }
                }) {
                    self.currentUser = value
                    self.saveCurrentUserLocally()
                }
            } catch {
                // Stream ended or Firestore error; avoid crashing the task.
            }
        }
    }

    private func saveCurrentUserLocally() {
        Task { @MainActor in
            do {
                try local.saveCurrentUser(user: currentUser)
            } catch {
                // Best-effort local cache.
            }
        }
    }

    func markOnboardingCompleteForCurrentUser() async throws {
        let uid = try currentUserId()
        try await remote.markOnboardingCompleted(userId: uid)
        currentUser?.didCompleteOnboarding = true
        try local.saveCurrentUser(user: currentUser)
    }

    func signOut() {
        currentUserListener?.remove()
        currentUserListener = nil
        currentUser = nil
        local.clearUserData()
    }

    func deleteCurrentUser() async throws {
        let uid = try currentUserId()
        try await remote.deleteUser(userId: uid)
        signOut()
    }

    private func currentUserId() throws -> String {
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return uid
    }

    enum UserManagerError: LocalizedError {
        case noUserId
    }
}

@MainActor
protocol OnboardingCompletionSyncing: AnyObject {
    func markOnboardingCompleteForCurrentUser() async throws
}

extension UserManager: OnboardingCompletionSyncing {}

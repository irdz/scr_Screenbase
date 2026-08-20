//
//  FirebaseAuthServiceLive.swift
//  Screenbase
//

import FirebaseAuth
import Foundation

/// Enable **Anonymous** sign-in in the Firebase Console (Authentication > Sign-in method).
struct FirebaseAuthServiceLive: AuthService {
    func addAuthenticatedUserListener(onListenerAttached: @escaping @Sendable (any NSObjectProtocol) -> Void)
    -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            let listener = Auth.auth().addStateDidChangeListener { _, currentUser in
                if let currentUser {
                    continuation.yield(UserAuthInfo(user: currentUser))
                } else {
                    continuation.yield(nil)
                }
            }
            onListenerAttached(listener)
        }
    }

    func getAuthenticatedUser() -> UserAuthInfo? {
        guard let user = Auth.auth().currentUser else { return nil }
        return UserAuthInfo(user: user)
    }

    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await Auth.auth().signInAnonymously()
        let user = UserAuthInfo(user: result.user)
        let isNewUser = result.additionalUserInfo?.isNewUser ?? true
        return (user, isNewUser)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw FirebaseAuthServiceLiveError.userNotFound
        }
        try await user.delete()
    }

    enum FirebaseAuthServiceLiveError: LocalizedError {
        case userNotFound

        var errorDescription: String? {
            switch self {
            case .userNotFound:
                "Current authenticated user not found"
            }
        }
    }
}

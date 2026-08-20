//
//  AuthServiceMock.swift
//  Screenbase
//

import Foundation

/// Test/preview double for ``AuthService`` (use from `@MainActor` tests only).
final class AuthServiceMock: AuthService, @unchecked Sendable {
    private var storedUser: UserAuthInfo?

    init(user: UserAuthInfo? = .mock) {
        storedUser = user
    }

    func setUser(_ user: UserAuthInfo?) {
        storedUser = user
    }

    func addAuthenticatedUserListener(onListenerAttached: @escaping @Sendable (any NSObjectProtocol) -> Void)
    -> AsyncStream<UserAuthInfo?> {
        let initial = getAuthenticatedUser()
        return AsyncStream { continuation in
            continuation.yield(initial)
            continuation.finish()
        }
    }

    func getAuthenticatedUser() -> UserAuthInfo? {
        storedUser
    }

    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo(
            uid: "mock_anon_\(UUID().uuidString.prefix(8))",
            email: nil,
            isAnonymous: true,
            creationDate: .now,
            lastSignInDate: .now
        )
        storedUser = user
        return (user, true)
    }

    func signOut() throws {
        storedUser = nil
    }

    func deleteAccount() async throws {
        try signOut()
    }
}

//
//  AuthManager.swift
//  Screenbase
//

import Foundation
import Observation

@MainActor
@Observable
final class AuthManager {
    private let service: AuthService
    private(set) var auth: UserAuthInfo?
    private var listenerToken: (any NSObjectProtocol)?

    init(service: AuthService) {
        self.service = service
        auth = service.getAuthenticatedUser()
        startAuthListener()
    }

    private func startAuthListener() {
        Task {
            for await value in service.addAuthenticatedUserListener(onListenerAttached: { token in
                Task { @MainActor in
                    self.listenerToken = token
                }
            }) {
                self.auth = value
            }
        }
    }

    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await service.signInAnonymously()
        auth = result.user
        return result
    }

    func signOut() throws {
        try service.signOut()
        auth = nil
    }

    func deleteAccount() async throws {
        try await service.deleteAccount()
        auth = nil
    }

    func getAuthId() throws -> String {
        guard let uid = auth?.uid else {
            throw AuthError.notSignedIn
        }
        return uid
    }

    enum AuthError: LocalizedError {
        case notSignedIn
    }
}

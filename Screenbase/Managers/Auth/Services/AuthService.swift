//
//  AuthService.swift
//  Screenbase
//

import Foundation

protocol AuthService: Sendable {
    func addAuthenticatedUserListener(onListenerAttached: @escaping @Sendable (any NSObjectProtocol) -> Void)
        -> AsyncStream<UserAuthInfo?>
    func getAuthenticatedUser() -> UserAuthInfo?
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signOut() throws
    func deleteAccount() async throws
}

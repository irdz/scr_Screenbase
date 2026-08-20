//
//  AppDelegate_Tests.swift
//  ScreenbaseTests
//

import FirebaseCore
@testable import Screenbase
import Testing

@Suite("AppDelegate Tests")
struct AppDelegate_Tests {
    @Test("Test host skips Firebase and uses mock dependencies")
    @MainActor
    func hostUsesMockDependencies() {
        #expect(AppDelegate.shouldUseMockDependencies)
        #expect(FirebaseApp.app() == nil)
    }

    @Test("Mock dependencies sign in without Firebase")
    @MainActor
    func mockDependenciesSignInWithoutFirebase() async throws {
        let dependencies = AppDependencies.mock

        let result = try await dependencies.authManager.signInAnonymously()
        try await dependencies.userManager.login(auth: result.user, isNewUser: result.isNewUser)

        let user = try #require(dependencies.userManager.currentUser)
        #expect(user.userId == result.user.uid)
        #expect(FirebaseApp.app() == nil)
    }
}

import Testing
@testable import Screenbase

@Suite("UserManager Tests")
struct UserManager_Tests {

    @Test("Login stores current user from auth")
    @MainActor
    func loginStoresCurrentUser() async throws {
        let sut = UserManager(services: MockUserServices())

        try await sut.login(auth: .mock, isNewUser: true)

        let user = try #require(sut.currentUser)
        #expect(user.userId == UserAuthInfo.mock.uid)
        #expect(user.isAnonymous == true)
    }

    @Test("Mark onboarding complete updates profile")
    @MainActor
    func markOnboardingCompleteUpdatesProfile() async throws {
        let services = MockUserServices()
        let sut = UserManager(services: services)

        try await sut.login(auth: .mock, isNewUser: true)
        try await sut.markOnboardingCompleteForCurrentUser()

        let stored = try #require(services.local.getCurrentUser())
        #expect(stored.didCompleteOnboarding == true)
    }
}

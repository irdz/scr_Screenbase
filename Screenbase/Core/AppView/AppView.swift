//
//  AppView.swift
//  Screenbase
//

import SwiftUI

struct AppView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(PhotosManager.self) private var photosManager

    @State private var appState = AppState()

    var body: some View {
        AppViewBuilder(showMainApp: appState.showMainApp) {
            MainTabView()
        } onboardingView: {
            ScreenbaseOnboardingView(appState: appState, photosManager: photosManager)
        }
        .environment(appState)
        .task {
            await checkUserStatus()
        }
    }

    private func checkUserStatus() async {
        if let user = authManager.auth {
            do {
                try await userManager.login(auth: user, isNewUser: false)
            } catch {
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            do {
                let result = try await authManager.signInAnonymously()
                try await userManager.login(auth: result.user, isNewUser: result.isNewUser)
            } catch {
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
}

#Preview("Screenbase App — Main") {
    AppView()
        .environment(AuthManager(service: AuthServiceMock()))
        .environment(UserManager(services: MockUserServices()))
        .environment(PhotosManager(service: MockPhotosService(status: .authorized, screenshotCount: 24)))
}

#Preview("Screenbase App — Onboarding") {
    AppView()
        .environment(AuthManager(service: AuthServiceMock(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(PhotosManager(service: MockPhotosService()))
}

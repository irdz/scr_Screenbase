//
//  AppDelegate.swift
//  Screenbase
//

import FirebaseCore
import Foundation
import UIKit

enum BuildConfiguration {
    case dev
    case prod

    func configureFirebase() {
        switch self {
        case .dev:
            let plist = Self.googleServicePlistPath(resourceName: "GoogleService-Info-Dev")
            guard let options = FirebaseOptions(contentsOfFile: plist) else {
                fatalError("Invalid Firebase plist at \(plist).")
            }
            FirebaseApp.configure(options: options)
        case .prod:
            let plist = Self.googleServicePlistPath(resourceName: "GoogleService-Info-Prod")
            guard let options = FirebaseOptions(contentsOfFile: plist) else {
                fatalError("Invalid Firebase plist at \(plist).")
            }
            FirebaseApp.configure(options: options)
        }
    }

    /// Resolves `GoogleServicePLists/<name>.plist` when present in the bundle, otherwise the bundle root.
    private static func googleServicePlistPath(resourceName: String) -> String {
        if let path = Bundle.main.path(forResource: resourceName, ofType: "plist", inDirectory: "GoogleServicePLists") {
            return path
        }
        guard let path = Bundle.main.path(forResource: resourceName, ofType: "plist") else {
            fatalError(
                "Missing \(resourceName).plist for Firebase. Add it under Screenbase/GoogleServicePLists/."
            )
        }
        return path
    }
}

struct AppDependencies {
    let authManager: AuthManager
    let userManager: UserManager
    let photosManager: PhotosManager

    init(authManager: AuthManager, userManager: UserManager, photosManager: PhotosManager) {
        self.authManager = authManager
        self.userManager = userManager
        self.photosManager = photosManager
    }

    init(configuration: BuildConfiguration) {
        switch configuration {
        case .dev, .prod:
            self.init(
                authManager: AuthManager(service: FirebaseAuthServiceLive()),
                userManager: UserManager(services: ProductionUserServices()),
                photosManager: PhotosManager(service: PhotosServiceLive())
            )
        }
    }

    static var mock: AppDependencies {
        AppDependencies(
            authManager: AuthManager(service: AuthServiceMock()),
            userManager: UserManager(services: MockUserServices()),
            photosManager: PhotosManager(service: MockPhotosService())
        )
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: AppDependencies!

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if Self.shouldUseMockDependencies {
            dependencies = .mock
            return true
        }

        let configuration: BuildConfiguration
        #if DEV
        configuration = .dev
        #else
        configuration = .prod
        #endif

        configuration.configureFirebase()
        dependencies = AppDependencies(configuration: configuration)
        return true
    }

    /// Unit tests and SwiftUI previews skip Firebase so placeholder GoogleService plists (SCR-33) don't abort launch.
    private static var shouldUseMockDependencies: Bool {
        let environment = ProcessInfo.processInfo.environment
        return environment["XCTestConfigurationFilePath"] != nil
            || environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}

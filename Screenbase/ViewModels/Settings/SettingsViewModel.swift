//
//  SettingsViewModel.swift
//  Screenbase
//

import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    enum Keys {
        static let deleteAfterImport = "screenbase_deleteAfterImport"
        static let autoGroupScreenshots = "screenbase_autoGroupScreenshots"
        static let automaticAnalysis = "screenbase_automaticAnalysis"
        static let showAnnotationsByDefault = "screenbase_showAnnotationsByDefault"
        static let includeScreenshotText = "screenbase_includeScreenshotText"
        static let includeVisualAnalysis = "screenbase_includeVisualAnalysis"
        static let autoTag = "screenbase_autoTag"
        static let appearance = "screenbase_appearance"
        static let analyticsEnabled = "screenbase_analyticsEnabled"
    }

    var deleteAfterImport: Bool {
        didSet { defaults.set(deleteAfterImport, forKey: Keys.deleteAfterImport) }
    }

    var autoGroupScreenshots: Bool {
        didSet { defaults.set(autoGroupScreenshots, forKey: Keys.autoGroupScreenshots) }
    }

    var automaticAnalysis: Bool {
        didSet { defaults.set(automaticAnalysis, forKey: Keys.automaticAnalysis) }
    }

    var showAnnotationsByDefault: Bool {
        didSet { defaults.set(showAnnotationsByDefault, forKey: Keys.showAnnotationsByDefault) }
    }

    var includeScreenshotText: Bool {
        didSet { defaults.set(includeScreenshotText, forKey: Keys.includeScreenshotText) }
    }

    var includeVisualAnalysis: Bool {
        didSet { defaults.set(includeVisualAnalysis, forKey: Keys.includeVisualAnalysis) }
    }

    var autoTag: Bool {
        didSet { defaults.set(autoTag, forKey: Keys.autoTag) }
    }

    var appearance: AppearancePreference {
        didSet { defaults.set(appearance.rawValue, forKey: Keys.appearance) }
    }

    var analyticsEnabled: Bool {
        didSet { defaults.set(analyticsEnabled, forKey: Keys.analyticsEnabled) }
    }

    let storageUsedDisplay: String
    let subscriptionStatus: String
    let versionDisplay: String

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard, bundle: Bundle = .main) {
        self.defaults = defaults
        deleteAfterImport = defaults.bool(forKey: Keys.deleteAfterImport)
        autoGroupScreenshots = Self.storedBool(defaults, key: Keys.autoGroupScreenshots, default: true)
        automaticAnalysis = Self.storedBool(defaults, key: Keys.automaticAnalysis, default: true)
        showAnnotationsByDefault = defaults.bool(forKey: Keys.showAnnotationsByDefault)
        includeScreenshotText = Self.storedBool(defaults, key: Keys.includeScreenshotText, default: true)
        includeVisualAnalysis = Self.storedBool(defaults, key: Keys.includeVisualAnalysis, default: true)
        autoTag = Self.storedBool(defaults, key: Keys.autoTag, default: true)
        analyticsEnabled = defaults.bool(forKey: Keys.analyticsEnabled)

        let rawAppearance = defaults.string(forKey: Keys.appearance) ?? AppearancePreference.system.rawValue
        appearance = AppearancePreference(rawValue: rawAppearance) ?? .system

        storageUsedDisplay = "0 MB"
        subscriptionStatus = "Not subscribed"

        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        versionDisplay = "\(version) (\(build))"
    }

    private static func storedBool(_ defaults: UserDefaults, key: String, default defaultValue: Bool) -> Bool {
        guard defaults.object(forKey: key) != nil else {
            return defaultValue
        }
        return defaults.bool(forKey: key)
    }
}

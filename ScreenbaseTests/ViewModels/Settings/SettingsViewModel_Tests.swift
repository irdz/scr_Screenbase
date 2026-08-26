import Foundation
@testable import Screenbase
import Testing

@Suite("SettingsViewModel Tests")
struct SettingsViewModel_Tests {
    @Test("Unset defaults match launch values")
    @MainActor
    func unsetDefaultsMatchLaunchValues() throws {
        let suite = "screenbase.settings.tests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let sut = SettingsViewModel(defaults: defaults)

        #expect(sut.deleteAfterImport == false)
        #expect(sut.autoGroupScreenshots)
        #expect(sut.automaticAnalysis)
        #expect(sut.showAnnotationsByDefault == false)
        #expect(sut.includeScreenshotText)
        #expect(sut.includeVisualAnalysis)
        #expect(sut.autoTag)
        #expect(sut.analyticsEnabled == false)
        #expect(sut.appearance == .system)
        #expect(sut.storageUsedDisplay == "0 MB")
        #expect(sut.subscriptionStatus == "Not subscribed")
    }

    @Test("Toggles persist across launches")
    @MainActor
    func togglesPersistAcrossLaunches() throws {
        let suite = "screenbase.settings.tests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let sut = SettingsViewModel(defaults: defaults)
        sut.deleteAfterImport = true
        sut.includeScreenshotText = false
        sut.appearance = .dark

        let reloaded = SettingsViewModel(defaults: defaults)

        #expect(reloaded.deleteAfterImport)
        #expect(reloaded.includeScreenshotText == false)
        #expect(reloaded.appearance == .dark)
    }
}

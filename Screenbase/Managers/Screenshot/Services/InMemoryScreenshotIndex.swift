//
//  InMemoryScreenshotIndex.swift
//  Screenbase
//

import Foundation

/// Ephemeral screenshot index used until the SCR-7 metadata store is wired in.
@MainActor
final class InMemoryScreenshotIndex: ScreenshotIndexing {
    private(set) var indexedAssetIdentifiers: Set<String> = []
    private(set) var indexedScreenshots: [DiscoveredScreenshot] = []

    func indexNewScreenshots(_ screenshots: [DiscoveredScreenshot]) async throws {
        for screenshot in screenshots where !indexedAssetIdentifiers.contains(screenshot.assetLocalIdentifier) {
            indexedAssetIdentifiers.insert(screenshot.assetLocalIdentifier)
            indexedScreenshots.append(screenshot)
        }
    }
}

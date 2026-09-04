//
//  ScreenshotIndexing.swift
//  Screenbase
//

import Foundation

/// Persistence boundary for discovered screenshots.
/// SCR-6 ships an in-memory implementation; SCR-7 replaces it with the metadata store.
@MainActor
protocol ScreenshotIndexing: AnyObject {
    var indexedAssetIdentifiers: Set<String> { get }

    /// Persists screenshots that are not already indexed. Idempotent for known asset IDs.
    func indexNewScreenshots(_ screenshots: [DiscoveredScreenshot]) async throws
}

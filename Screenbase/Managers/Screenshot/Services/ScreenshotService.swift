//
//  ScreenshotService.swift
//  Screenbase
//

import Foundation

enum ScreenshotServiceError: Error, Equatable {
    case notAuthorized
}

@MainActor
protocol ScreenshotService {
    /// Fetches every image asset tagged as a screenshot. Does not include regular photos.
    func fetchScreenshots() async throws -> [DiscoveredScreenshot]

    /// Emits when the photo library changes so callers can re-scan for new screenshots.
    func libraryChangeEvents() -> AsyncStream<Void>
}

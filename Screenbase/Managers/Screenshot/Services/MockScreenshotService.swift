//
//  MockScreenshotService.swift
//  Screenbase
//

import Foundation

@MainActor
final class MockScreenshotService: ScreenshotService {
    var screenshots: [DiscoveredScreenshot]
    var isAuthorized: Bool
    var fetchCallCount = 0

    private var changeContinuation: AsyncStream<Void>.Continuation?
    private var pendingChangeEvents = 0

    init(
        screenshots: [DiscoveredScreenshot] = DiscoveredScreenshot.mocks,
        isAuthorized: Bool = true
    ) {
        self.screenshots = screenshots
        self.isAuthorized = isAuthorized
    }

    func fetchScreenshots() async throws -> [DiscoveredScreenshot] {
        fetchCallCount += 1
        guard isAuthorized else { throw ScreenshotServiceError.notAuthorized }
        return screenshots
    }

    func libraryChangeEvents() -> AsyncStream<Void> {
        AsyncStream { continuation in
            changeContinuation = continuation
            for _ in 0 ..< pendingChangeEvents {
                continuation.yield(())
            }
            pendingChangeEvents = 0
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor in
                    self?.changeContinuation = nil
                }
            }
        }
    }

    /// Simulates a photo-library change that should trigger a re-scan.
    func emitLibraryChange() {
        if let changeContinuation {
            changeContinuation.yield(())
        } else {
            pendingChangeEvents += 1
        }
    }
}

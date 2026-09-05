//
//  LibraryViewModel.swift
//  Screenbase
//

import Foundation
import Observation

@MainActor
@Observable
final class LibraryViewModel {
    enum ContentState: Equatable {
        case loading
        case empty
        case populated
    }

    var selectedFilter: LibraryFilter = .all
    var isSelecting = false
    var selectedScreenshotIds: Set<String> = []
    var isAddSheetPresented = false
    var detailScreenshotId: String?

    private let metadataManager: MetadataManager
    private let screenshotManager: ScreenshotManager
    private let favoriteTagName = "favorite"
    private let recentInterval: TimeInterval = 7 * 24 * 60 * 60

    init(metadataManager: MetadataManager, screenshotManager: ScreenshotManager) {
        self.metadataManager = metadataManager
        self.screenshotManager = screenshotManager
    }

    var contentState: ContentState {
        if !filteredScreenshots.isEmpty {
            return .populated
        }
        if screenshotManager.isScanning, metadataManager.screenshots.isEmpty {
            return .loading
        }
        return .empty
    }

    /// Newest capture first (falls back to createdAt).
    var filteredScreenshots: [ScreenshotRecord] {
        let sorted = metadataManager.screenshots.sorted { lhs, rhs in
            let left = lhs.captureDate ?? lhs.createdAt
            let right = rhs.captureDate ?? rhs.createdAt
            return left > right
        }

        switch selectedFilter {
        case .all:
            return sorted
        case .collections:
            return sorted.filter { !$0.collectionIds.isEmpty }
        case .favorites:
            let favoriteIds = Set(
                metadataManager.tags
                    .filter {
                        $0.name
                            .compare(favoriteTagName, options: [.caseInsensitive, .diacriticInsensitive]) ==
                            .orderedSame
                    }
                    .map(\.id)
            )
            return sorted.filter { record in
                record.tagIds.contains { favoriteIds.contains($0) }
            }
        case .recent:
            let cutoff = Date().addingTimeInterval(-recentInterval)
            return sorted.filter { ($0.captureDate ?? $0.createdAt) >= cutoff }
        }
    }

    var skeletonTileCount: Int {
        12
    }

    func selectFilter(_ filter: LibraryFilter) {
        selectedFilter = filter
    }

    func toggleSelecting() {
        isSelecting.toggle()
        if !isSelecting {
            selectedScreenshotIds.removeAll()
        }
    }

    func handleTileTap(screenshotId: String) {
        if isSelecting {
            if selectedScreenshotIds.contains(screenshotId) {
                selectedScreenshotIds.remove(screenshotId)
            } else {
                selectedScreenshotIds.insert(screenshotId)
            }
        } else {
            detailScreenshotId = screenshotId
        }
    }

    func isSelected(_ screenshotId: String) -> Bool {
        selectedScreenshotIds.contains(screenshotId)
    }

    func presentAddSheet() {
        isAddSheetPresented = true
    }

    func clearDetail() {
        detailScreenshotId = nil
    }
}

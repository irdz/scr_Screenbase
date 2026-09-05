//
//  CollectionDetailViewModel.swift
//  Screenbase
//

import Foundation
import Observation

@MainActor
@Observable
final class CollectionDetailViewModel {
    enum ContentState: Equatable {
        case empty
        case populated
    }

    let collectionId: String
    var detailScreenshotId: String?

    private let metadataManager: MetadataManager

    init(collectionId: String, metadataManager: MetadataManager) {
        self.collectionId = collectionId
        self.metadataManager = metadataManager
    }

    var collection: CollectionRecord? {
        metadataManager.collections.first { $0.id == collectionId }
    }

    var title: String {
        collection?.name ?? "Collection"
    }

    /// Newest capture first (falls back to createdAt).
    var screenshots: [ScreenshotRecord] {
        metadataManager.screenshots(inCollection: collectionId).sorted { lhs, rhs in
            let left = lhs.captureDate ?? lhs.createdAt
            let right = rhs.captureDate ?? rhs.createdAt
            return left > right
        }
    }

    var contentState: ContentState {
        screenshots.isEmpty ? .empty : .populated
    }

    func handleTileTap(screenshotId: String) {
        detailScreenshotId = screenshotId
    }

    func clearDetail() {
        detailScreenshotId = nil
    }
}

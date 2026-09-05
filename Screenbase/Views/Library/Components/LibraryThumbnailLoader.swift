//
//  LibraryThumbnailLoader.swift
//  Screenbase
//

import CoreGraphics
import Observation
import UIKit

/// Caches Photos thumbnails for visible Library tiles.
@MainActor
@Observable
final class LibraryThumbnailLoader {
    private(set) var images: [String: UIImage] = [:]

    private let photosManager: PhotosManager
    private var inFlight: Set<String> = []
    private let targetSize: CGSize

    init(photosManager: PhotosManager, pointSize: CGFloat = 180) {
        self.photosManager = photosManager
        let scale = UIScreen.main.scale
        targetSize = CGSize(width: pointSize * scale, height: pointSize * scale)
    }

    func image(for assetLocalIdentifier: String) -> UIImage? {
        images[assetLocalIdentifier]
    }

    func loadIfNeeded(assetLocalIdentifier: String) {
        guard images[assetLocalIdentifier] == nil, !inFlight.contains(assetLocalIdentifier) else { return }
        inFlight.insert(assetLocalIdentifier)
        Task {
            let image = await photosManager.thumbnailImage(
                forAssetLocalIdentifier: assetLocalIdentifier,
                targetSize: targetSize
            )
            if let image {
                images[assetLocalIdentifier] = image
            }
            inFlight.remove(assetLocalIdentifier)
        }
    }
}

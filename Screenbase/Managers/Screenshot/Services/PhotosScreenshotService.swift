//
//  PhotosScreenshotService.swift
//  Screenbase
//

import Foundation
import Photos

/// Live Photos fetch + change observer scoped to `PHAssetMediaSubtype.photoScreenshot`.
@MainActor
final class PhotosScreenshotService: ScreenshotService {
    private let changeObserver: PhotoLibraryChangeObserver

    init() {
        changeObserver = PhotoLibraryChangeObserver()
    }

    func fetchScreenshots() async throws -> [DiscoveredScreenshot] {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard status == .authorized || status == .limited else {
            throw ScreenshotServiceError.notAuthorized
        }

        return await Task.detached(priority: .userInitiated) {
            let options = PHFetchOptions()
            options.predicate = NSPredicate(
                format: "(mediaSubtype & %d) != 0",
                PHAssetMediaSubtype.photoScreenshot.rawValue
            )
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

            let result = PHAsset.fetchAssets(with: .image, options: options)
            var screenshots: [DiscoveredScreenshot] = []
            screenshots.reserveCapacity(result.count)
            result.enumerateObjects { asset, _, _ in
                screenshots.append(
                    DiscoveredScreenshot(
                        assetLocalIdentifier: asset.localIdentifier,
                        creationDate: asset.creationDate
                    )
                )
            }
            return screenshots
        }.value
    }

    func libraryChangeEvents() -> AsyncStream<Void> {
        changeObserver.events
    }
}

/// Registers with `PHPhotoLibrary` and forwards change notifications as an `AsyncStream`.
private final class PhotoLibraryChangeObserver: NSObject, PHPhotoLibraryChangeObserver, @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: AsyncStream<Void>.Continuation?
    private var isRegistered = false

    lazy var events: AsyncStream<Void> = AsyncStream { continuation in
        self.lock.lock()
        self.continuation = continuation
        self.lock.unlock()

        continuation.onTermination = { [weak self] _ in
            self?.unregister()
        }

        self.registerIfNeeded()
    }

    func photoLibraryDidChange(_: PHChange) {
        lock.lock()
        let continuation = continuation
        lock.unlock()
        continuation?.yield(())
    }

    private func registerIfNeeded() {
        lock.lock()
        defer { lock.unlock() }
        guard !isRegistered else { return }
        PHPhotoLibrary.shared().register(self)
        isRegistered = true
    }

    private func unregister() {
        lock.lock()
        let shouldUnregister = isRegistered
        isRegistered = false
        continuation = nil
        lock.unlock()
        if shouldUnregister {
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
        }
    }

    deinit {
        unregister()
    }
}

//
//  PhotosServiceLive.swift
//  Screenbase
//

import Foundation
import Photos
import UIKit

struct PhotosServiceLive: PhotosService {
    var authorizationStatus: PhotosAuthorizationStatus {
        PhotosAuthorizationStatus(PHPhotoLibrary.authorizationStatus(for: .readWrite))
    }

    func requestAuthorization() async -> PhotosAuthorizationStatus {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return PhotosAuthorizationStatus(status)
    }

    func screenshotCount() async throws -> Int {
        let status = authorizationStatus
        guard status == .authorized || status == .limited else {
            throw PhotosServiceError.notAuthorized
        }

        return await Task.detached(priority: .userInitiated) {
            let options = PHFetchOptions()
            options.predicate = NSPredicate(
                format: "(mediaSubtype & %d) != 0",
                PHAssetMediaSubtype.photoScreenshot.rawValue
            )
            let result = PHAsset.fetchAssets(with: .image, options: options)
            return result.count
        }.value
    }

    func thumbnailImage(forAssetLocalIdentifier localIdentifier: String, targetSize: CGSize) async -> UIImage? {
        let status = authorizationStatus
        guard status == .authorized || status == .limited else { return nil }

        return await withCheckedContinuation { continuation in
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
            guard let asset = assets.firstObject else {
                continuation.resume(returning: nil)
                return
            }

            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .fast
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}

private extension PhotosAuthorizationStatus {
    init(_ status: PHAuthorizationStatus) {
        switch status {
        case .notDetermined:
            self = .notDetermined
        case .authorized:
            self = .authorized
        case .limited:
            self = .limited
        case .denied, .restricted:
            self = .denied
        @unknown default:
            self = .denied
        }
    }
}

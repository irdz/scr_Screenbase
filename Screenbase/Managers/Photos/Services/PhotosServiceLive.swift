//
//  PhotosServiceLive.swift
//  Screenbase
//

import Foundation
import Photos

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

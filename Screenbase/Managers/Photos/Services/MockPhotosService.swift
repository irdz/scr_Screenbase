//
//  MockPhotosService.swift
//  Screenbase
//

import CoreGraphics
import Foundation
import UIKit

@MainActor
final class MockPhotosService: PhotosService {
    var authorizationStatus: PhotosAuthorizationStatus
    var screenshotCountValue: Int
    var requestDelayNanoseconds: UInt64
    var scanDelayNanoseconds: UInt64
    var thumbnailImages: [String: UIImage]
    var fullImages: [String: UIImage]
    var missingAssetIdentifiers: Set<String>

    init(
        status: PhotosAuthorizationStatus = .notDetermined,
        screenshotCount: Int = 12,
        requestDelayNanoseconds: UInt64 = 0,
        scanDelayNanoseconds: UInt64 = 0,
        thumbnailImages: [String: UIImage] = [:],
        fullImages: [String: UIImage] = [:],
        missingAssetIdentifiers: Set<String> = []
    ) {
        authorizationStatus = status
        screenshotCountValue = screenshotCount
        self.requestDelayNanoseconds = requestDelayNanoseconds
        self.scanDelayNanoseconds = scanDelayNanoseconds
        self.thumbnailImages = thumbnailImages
        self.fullImages = fullImages
        self.missingAssetIdentifiers = missingAssetIdentifiers
    }

    func requestAuthorization() async -> PhotosAuthorizationStatus {
        if requestDelayNanoseconds > 0 {
            try? await Task.sleep(nanoseconds: requestDelayNanoseconds)
        }
        if authorizationStatus == .notDetermined {
            authorizationStatus = .authorized
        }
        return authorizationStatus
    }

    func screenshotCount() async throws -> Int {
        guard authorizationStatus == .authorized || authorizationStatus == .limited else {
            throw PhotosServiceError.notAuthorized
        }
        if scanDelayNanoseconds > 0 {
            try? await Task.sleep(nanoseconds: scanDelayNanoseconds)
        }
        return screenshotCountValue
    }

    func thumbnailImage(forAssetLocalIdentifier localIdentifier: String, targetSize _: CGSize) async -> UIImage? {
        guard authorizationStatus == .authorized || authorizationStatus == .limited else { return nil }
        guard !missingAssetIdentifiers.contains(localIdentifier) else { return nil }
        return thumbnailImages[localIdentifier]
    }

    func fullImage(forAssetLocalIdentifier localIdentifier: String, targetSize _: CGSize) async -> UIImage? {
        guard authorizationStatus == .authorized || authorizationStatus == .limited else { return nil }
        guard !missingAssetIdentifiers.contains(localIdentifier) else { return nil }
        return fullImages[localIdentifier] ?? thumbnailImages[localIdentifier]
    }
}

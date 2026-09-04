//
//  PhotosService.swift
//  Screenbase
//

import CoreGraphics
import Foundation
import UIKit

enum PhotosAuthorizationStatus: Equatable, Sendable {
    case notDetermined
    case authorized
    case limited
    case denied
}

enum PhotosServiceError: Error {
    case notAuthorized
}

@MainActor
protocol PhotosService {
    var authorizationStatus: PhotosAuthorizationStatus { get }

    func requestAuthorization() async -> PhotosAuthorizationStatus
    func screenshotCount() async throws -> Int

    /// Loads a square-ish thumbnail for a Photos asset. Returns `nil` if unavailable.
    func thumbnailImage(forAssetLocalIdentifier localIdentifier: String, targetSize: CGSize) async -> UIImage?
}

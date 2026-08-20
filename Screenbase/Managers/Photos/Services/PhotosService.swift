//
//  PhotosService.swift
//  Screenbase
//

import Foundation

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
}

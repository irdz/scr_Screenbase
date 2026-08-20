//
//  PhotosManager.swift
//  Screenbase
//

import Foundation
import Observation

@MainActor
@Observable
final class PhotosManager {
    private let service: any PhotosService

    private(set) var authorizationStatus: PhotosAuthorizationStatus

    init(service: any PhotosService) {
        self.service = service
        authorizationStatus = service.authorizationStatus
    }

    func requestAuthorization() async -> PhotosAuthorizationStatus {
        authorizationStatus = await service.requestAuthorization()
        return authorizationStatus
    }

    func screenshotCount() async throws -> Int {
        try await service.screenshotCount()
    }
}

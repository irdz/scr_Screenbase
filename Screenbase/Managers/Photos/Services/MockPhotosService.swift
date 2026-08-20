//
//  MockPhotosService.swift
//  Screenbase
//

import Foundation

@MainActor
final class MockPhotosService: PhotosService {
    var authorizationStatus: PhotosAuthorizationStatus
    var screenshotCountValue: Int
    var requestDelayNanoseconds: UInt64
    var scanDelayNanoseconds: UInt64

    init(
        status: PhotosAuthorizationStatus = .notDetermined,
        screenshotCount: Int = 12,
        requestDelayNanoseconds: UInt64 = 0,
        scanDelayNanoseconds: UInt64 = 0
    ) {
        authorizationStatus = status
        screenshotCountValue = screenshotCount
        self.requestDelayNanoseconds = requestDelayNanoseconds
        self.scanDelayNanoseconds = scanDelayNanoseconds
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
}

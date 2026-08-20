//
//  OnboardingViewModel.swift
//  Screenbase
//

import Foundation
import Observation

@MainActor
@Observable
final class OnboardingViewModel {
    enum Step: Int, CaseIterable, Equatable {
        case welcome
        case photosPermission
        case initialScan
    }

    private(set) var step: Step
    private(set) var photosStatus: PhotosAuthorizationStatus
    private(set) var isRequestingPhotos = false
    private(set) var isScanning = false
    private(set) var screenshotCount: Int?
    private(set) var scanFailed = false

    private let photosManager: PhotosManager

    init(photosManager: PhotosManager, step: Step = .welcome) {
        self.photosManager = photosManager
        self.step = step
        photosStatus = photosManager.authorizationStatus
    }

    var primaryButtonTitle: String {
        switch step {
        case .welcome:
            OnboardingCopy.Welcome.continueCTA
        case .photosPermission:
            OnboardingCopy.PhotosPermission.enableCTA
        case .initialScan:
            OnboardingCopy.InitialScan.continueCTA
        }
    }

    var canContinueFromScan: Bool {
        !isScanning
    }

    func continueFromWelcome() {
        step = .photosPermission
        photosStatus = photosManager.authorizationStatus
    }

    func requestPhotosAccess() async {
        isRequestingPhotos = true
        photosStatus = await photosManager.requestAuthorization()
        isRequestingPhotos = false
        step = .initialScan
    }

    func skipPhotosPermission() {
        photosStatus = photosManager.authorizationStatus
        step = .initialScan
    }

    func startInitialScanIfNeeded() async {
        guard step == .initialScan, screenshotCount == nil, !isScanning else { return }
        photosStatus = photosManager.authorizationStatus
        guard photosStatus == .authorized || photosStatus == .limited else { return }

        isScanning = true
        scanFailed = false
        do {
            screenshotCount = try await photosManager.screenshotCount()
        } catch {
            scanFailed = true
        }
        isScanning = false
    }
}

@testable import Screenbase
import Testing

@Suite("OnboardingViewModel Tests")
struct OnboardingViewModel_Tests {
    @Test("Welcome continue advances to photos permission")
    @MainActor
    func continueFromWelcomeAdvancesToPhotos() {
        let photos = PhotosManager(service: MockPhotosService())
        let sut = OnboardingViewModel(photosManager: photos)

        sut.continueFromWelcome()

        #expect(sut.step == .photosPermission)
    }

    @Test("Photos request authorizes and advances to scan")
    @MainActor
    func requestPhotosAccessAdvancesToScan() async {
        let photos = PhotosManager(service: MockPhotosService(status: .notDetermined, screenshotCount: 7))
        let sut = OnboardingViewModel(photosManager: photos)

        await sut.requestPhotosAccess()

        #expect(sut.photosStatus == .authorized)
        #expect(sut.step == .initialScan)
    }

    @Test("Skip photos still advances to scan")
    @MainActor
    func skipPhotosPermissionAdvancesToScan() {
        let photos = PhotosManager(service: MockPhotosService(status: .notDetermined))
        let sut = OnboardingViewModel(photosManager: photos)

        sut.skipPhotosPermission()

        #expect(sut.step == .initialScan)
        #expect(sut.photosStatus == .notDetermined)
    }

    @Test("Authorized scan records screenshot count")
    @MainActor
    func startInitialScanRecordsCount() async {
        let photos = PhotosManager(service: MockPhotosService(status: .authorized, screenshotCount: 21))
        let sut = OnboardingViewModel(photosManager: photos, step: .initialScan)

        await sut.startInitialScanIfNeeded()

        #expect(sut.screenshotCount == 21)
        #expect(sut.isScanning == false)
        #expect(sut.canContinueFromScan)
    }

    @Test("Denied photos skips scan")
    @MainActor
    func deniedPhotosSkipsScan() async {
        let photos = PhotosManager(service: MockPhotosService(status: .denied, screenshotCount: 21))
        let sut = OnboardingViewModel(photosManager: photos, step: .initialScan)

        await sut.startInitialScanIfNeeded()

        #expect(sut.screenshotCount == nil)
        #expect(sut.isScanning == false)
        #expect(sut.canContinueFromScan)
    }
}

import Foundation
@testable import Screenbase
import Testing

@Suite("AppState Tests")
struct AppState_Tests {
    @Test("Update view state persists showMainApp")
    @MainActor
    func updateViewStatePersists() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: AppState.Keys.showMainApp)
        let sut = AppState(showMainApp: false)

        sut.updateViewState(showMainApp: true)

        #expect(sut.showMainApp)
        #expect(defaults.bool(forKey: AppState.Keys.showMainApp))

        defaults.removeObject(forKey: AppState.Keys.showMainApp)
    }
}

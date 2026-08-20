//
//  AppState.swift
//  Screenbase
//

import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    enum Keys {
        static let showMainApp = "screenbase_showMainApp"
    }

    private(set) var showMainApp: Bool {
        didSet {
            UserDefaults.standard.set(showMainApp, forKey: Keys.showMainApp)
        }
    }

    init(showMainApp: Bool = UserDefaults.standard.bool(forKey: Keys.showMainApp)) {
        self.showMainApp = showMainApp
    }

    func updateViewState(showMainApp: Bool) {
        self.showMainApp = showMainApp
    }
}

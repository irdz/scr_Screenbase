//
//  RevenueCatBuildSettings.swift
//  Screenbase
//

enum RevenueCatBuildSettings {
    /// Public SDK key from the RevenueCat dashboard. Replace the prod key when available.
    static var publicSDKKey: String {
        #if DEV
        "test_eQCXxPvSEjOxUUntTZYgDGzFDRB"
        #else
        "test_eQCXxPvSEjOxUUntTZYgDGzFDRB"
        #endif
    }
}

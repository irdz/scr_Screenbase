//
//  ProSubscriptionAccess.swift
//  Screenbase
//

import Foundation

/// Minimal surface area that ViewModels depend on to gate Pro features.
/// Lets us inject a deterministic mock in tests without pulling in StoreKit / RevenueCat.
@MainActor
protocol ProSubscriptionAccess: AnyObject {
    var isPremiumUnlocked: Bool { get }
}

extension PurchaseManager: ProSubscriptionAccess {}

/// Deterministic double for ViewModel tests.
@MainActor
final class ProSubscriptionAccessMock: ProSubscriptionAccess {
    var isPremiumUnlocked: Bool

    init(isPremiumUnlocked: Bool = false) {
        self.isPremiumUnlocked = isPremiumUnlocked
    }
}

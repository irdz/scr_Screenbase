//
//  ProEntitlementState.swift
//  Screenbase
//

import Foundation

/// Pure entitlement logic for Screenbase Pro — testable without StoreKit or network.
enum ProEntitlementState {
    static func isUnlocked(entitlementIsActive: Bool?) -> Bool {
        entitlementIsActive == true
    }
}

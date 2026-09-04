//
//  ProEntitlementState_Tests.swift
//  ScreenbaseTests
//

@testable import Screenbase
import Testing

@Suite("ProEntitlementState Tests")
struct ProEntitlementState_Tests {
    @Test("Active entitlement unlocks Pro")
    func activeEntitlementUnlocksPro() {
        #expect(ProEntitlementState.isUnlocked(entitlementIsActive: true))
    }

    @Test("Inactive or missing entitlement stays locked")
    func inactiveOrMissingEntitlementStaysLocked() {
        #expect(ProEntitlementState.isUnlocked(entitlementIsActive: false) == false)
        #expect(ProEntitlementState.isUnlocked(entitlementIsActive: nil) == false)
    }
}

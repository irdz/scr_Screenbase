//
//  ScreenbasePaywallHost.swift
//  Screenbase
//

import RevenueCat
import RevenueCatUI
import SwiftUI

/// Wraps RevenueCat `PaywallView` with purchase completion handling for Screenbase Pro.
struct ScreenbasePaywallHost: View {
    @Environment(PurchaseManager.self) private var purchaseManager
    @Binding var isPresented: Bool
    var onPremiumPurchaseSuccess: () -> Void = {}

    var body: some View {
        PaywallView(displayCloseButton: true)
            .onRequestedDismissal {
                isPresented = false
            }
            .onPurchaseCompleted { customerInfo in
                guard ProEntitlementState.isUnlocked(
                    entitlementIsActive: customerInfo
                        .entitlements[purchaseManager.premiumEntitlementIdentifier]?.isActive
                ) else { return }
                isPresented = false
                DispatchQueue.main.async {
                    onPremiumPurchaseSuccess()
                }
            }
            .onRestoreCompleted { customerInfo in
                guard ProEntitlementState.isUnlocked(
                    entitlementIsActive: customerInfo
                        .entitlements[purchaseManager.premiumEntitlementIdentifier]?.isActive
                ) else { return }
                isPresented = false
            }
    }
}

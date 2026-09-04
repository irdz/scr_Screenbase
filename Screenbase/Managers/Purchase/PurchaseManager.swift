//
//  PurchaseManager.swift
//  Screenbase
//

import Foundation
import Observation
import RevenueCat

@MainActor
@Observable
final class PurchaseManager {
    private(set) var currentOffering: Offering?
    private(set) var availablePackages: [Package] = []
    private(set) var customerInfo: CustomerInfo?
    private(set) var isPremiumUnlocked = false
    private(set) var isLoading = false
    private(set) var isPurchasing = false
    private(set) var statusMessage: String?

    /// Premium entitlement identifier used for paywall and entitlement checks.
    private(set) var premiumEntitlementIdentifier: String = RevenueCatConfig.premiumEntitlement

    private let service: any PurchaseService
    private let monthlyPackageIdentifier: String
    private let yearlyPackageIdentifier: String
    private var customerInfoTask: Task<Void, Never>?

    init(service: any PurchaseService) {
        self.service = service
        monthlyPackageIdentifier = RevenueCatConfig.monthlyPackage
        yearlyPackageIdentifier = RevenueCatConfig.yearlyPackage
    }

    func configureIfNeeded() {
        guard !service.isConfigured else { return }
        let apiKey = RevenueCatBuildSettings.publicSDKKey
        guard !apiKey.isEmpty else {
            statusMessage = "Subscription configuration is unavailable."
            return
        }
        service.configure(apiKey: apiKey)
        observeCustomerInfoUpdates()
    }

    func bootstrap() async {
        configureIfNeeded()
        guard service.isConfigured else { return }
        await refreshAll()
    }

    func refreshAll() async {
        guard service.isConfigured else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            async let fetchedOfferings = service.fetchOfferings()
            async let fetchedCustomerInfo = service.fetchCustomerInfo()
            let offerings = try await fetchedOfferings
            let info = try await fetchedCustomerInfo
            apply(offerings: offerings, customerInfo: info)
            statusMessage = nil
        } catch {
            statusMessage = "Unable to refresh subscription data. Please try again."
        }
    }

    func purchase(_ package: Package) async {
        guard service.isConfigured else { return }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let info = try await service.purchase(package: package)
            apply(customerInfo: info)
            statusMessage = isPremiumUnlocked
                ? "Screenbase Pro is active."
                : "Purchase completed, but Pro access is still pending."
        } catch {
            let nsError = error as NSError
            if nsError.code == ErrorCode.purchaseCancelledError.rawValue {
                statusMessage = "Purchase was canceled."
            } else {
                statusMessage = "Unable to complete purchase. Please try again."
            }
        }
    }

    func restorePurchases() async {
        guard service.isConfigured else { return }

        do {
            let restoredInfo = try await service.restorePurchases()
            apply(customerInfo: restoredInfo)
            statusMessage = isPremiumUnlocked
                ? "Purchases restored. Screenbase Pro is active."
                : "No active purchases found to restore."
        } catch {
            statusMessage = "Unable to restore purchases right now."
        }
    }

    func package(for identifier: String) -> Package? {
        availablePackages.first(where: { $0.identifier == identifier })
    }

    private func observeCustomerInfoUpdates() {
        guard customerInfoTask == nil else { return }

        customerInfoTask = Task { [weak self] in
            guard let self else { return }
            for await updatedInfo in service.customerInfoUpdates() {
                apply(customerInfo: updatedInfo)
            }
        }
    }

    private func apply(offerings: Offerings, customerInfo: CustomerInfo) {
        currentOffering = offerings.current
        if let current = offerings.current {
            let preferredOrder = [monthlyPackageIdentifier, yearlyPackageIdentifier]
            let preferredPackages = preferredOrder.compactMap { id in
                current.availablePackages.first(where: { $0.identifier == id })
            }
            availablePackages = preferredPackages.isEmpty ? current.availablePackages : preferredPackages
        } else {
            availablePackages = []
        }
        apply(customerInfo: customerInfo)
    }

    private func apply(customerInfo: CustomerInfo) {
        self.customerInfo = customerInfo
        isPremiumUnlocked = ProEntitlementState.isUnlocked(
            entitlementIsActive: customerInfo.entitlements[premiumEntitlementIdentifier]?.isActive
        )
    }
}

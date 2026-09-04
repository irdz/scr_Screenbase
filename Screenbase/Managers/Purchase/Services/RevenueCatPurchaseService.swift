//
//  RevenueCatPurchaseService.swift
//  Screenbase
//

import Foundation
import RevenueCat

struct RevenueCatPurchaseService: PurchaseService {
    var isConfigured: Bool {
        Purchases.isConfigured
    }

    func configure(apiKey: String) {
        Purchases.logLevel = .info
        Purchases.configure(withAPIKey: apiKey)
    }

    func fetchOfferings() async throws -> Offerings {
        try await Purchases.shared.offerings()
    }

    func fetchCustomerInfo() async throws -> CustomerInfo {
        try await Purchases.shared.customerInfo()
    }

    func purchase(package: Package) async throws -> CustomerInfo {
        let result = try await Purchases.shared.purchase(package: package)
        return result.customerInfo
    }

    func restorePurchases() async throws -> CustomerInfo {
        try await Purchases.shared.restorePurchases()
    }

    func customerInfoUpdates() -> AsyncStream<CustomerInfo> {
        AsyncStream { continuation in
            let task = Task {
                for await info in Purchases.shared.customerInfoStream {
                    continuation.yield(info)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

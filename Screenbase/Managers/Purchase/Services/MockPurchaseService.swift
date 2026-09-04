//
//  MockPurchaseService.swift
//  Screenbase
//

import Foundation
import RevenueCat

@MainActor
final class MockPurchaseService: PurchaseService {
    private(set) var didConfigure = false
    private var customerInfoContinuation: AsyncStream<CustomerInfo>.Continuation?

    var isConfigured: Bool {
        didConfigure
    }

    func configure(apiKey: String) {
        _ = apiKey
        didConfigure = true
    }

    func fetchOfferings() async throws -> Offerings {
        throw MockPurchaseServiceError.offeringsUnavailable
    }

    func fetchCustomerInfo() async throws -> CustomerInfo {
        throw MockPurchaseServiceError.customerInfoUnavailable
    }

    func purchase(package: Package) async throws -> CustomerInfo {
        _ = package
        throw MockPurchaseServiceError.purchaseUnavailable
    }

    func restorePurchases() async throws -> CustomerInfo {
        throw MockPurchaseServiceError.restoreUnavailable
    }

    func customerInfoUpdates() -> AsyncStream<CustomerInfo> {
        AsyncStream { continuation in
            customerInfoContinuation = continuation
        }
    }

    enum MockPurchaseServiceError: Error {
        case offeringsUnavailable
        case customerInfoUnavailable
        case purchaseUnavailable
        case restoreUnavailable
    }
}

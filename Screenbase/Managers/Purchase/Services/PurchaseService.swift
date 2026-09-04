//
//  PurchaseService.swift
//  Screenbase
//

import Foundation
import RevenueCat

@MainActor
protocol PurchaseService: Sendable {
    var isConfigured: Bool { get }
    func configure(apiKey: String)
    func fetchOfferings() async throws -> Offerings
    func fetchCustomerInfo() async throws -> CustomerInfo
    func purchase(package: Package) async throws -> CustomerInfo
    func restorePurchases() async throws -> CustomerInfo
    func customerInfoUpdates() -> AsyncStream<CustomerInfo>
}

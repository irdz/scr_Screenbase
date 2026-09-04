//
//  DiscoveredScreenshot.swift
//  Screenbase
//

import Foundation

/// A Photos asset discovered as a screenshot (`PHAssetMediaSubtype.photoScreenshot`).
struct DiscoveredScreenshot: Equatable, Identifiable, Sendable, Hashable {
    var id: String { assetLocalIdentifier }

    /// Photos framework local identifier (`PHAsset.localIdentifier`).
    let assetLocalIdentifier: String
    let creationDate: Date?

    static let mock = DiscoveredScreenshot(
        assetLocalIdentifier: "MOCK/ASSET-1",
        creationDate: Date(timeIntervalSince1970: 1_700_000_000)
    )

    static let mocks: [DiscoveredScreenshot] = [
        .mock,
        DiscoveredScreenshot(
            assetLocalIdentifier: "MOCK/ASSET-2",
            creationDate: Date(timeIntervalSince1970: 1_700_000_100)
        ),
        DiscoveredScreenshot(
            assetLocalIdentifier: "MOCK/ASSET-3",
            creationDate: Date(timeIntervalSince1970: 1_700_000_200)
        ),
    ]
}

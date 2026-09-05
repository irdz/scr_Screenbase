//
//  CollectionRecord.swift
//  Screenbase
//

import Foundation

struct CollectionRecord: Codable, Equatable, Identifiable, Sendable, Hashable {
    var id: String
    var name: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        name: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    static let mock = CollectionRecord(
        id: "col_1",
        name: "Onboarding",
        createdAt: Date(timeIntervalSince1970: 1_700_000_000),
        updatedAt: Date(timeIntervalSince1970: 1_700_000_000)
    )
}

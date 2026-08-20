//
//  UserAuthInfo.swift
//  Screenbase
//

import Foundation

struct UserAuthInfo: Sendable {
    let uid: String
    let email: String?
    let isAnonymous: Bool
    let creationDate: Date?
    let lastSignInDate: Date?

    static let mock = UserAuthInfo(
        uid: "mock_user_1",
        email: nil,
        isAnonymous: true,
        creationDate: Date(timeIntervalSince1970: 1_700_000_000),
        lastSignInDate: Date(timeIntervalSince1970: 1_700_000_000)
    )
}

//
//  AppUserProfile.swift
//  Screenbase
//

import Foundation

/// Firestore `users/{uid}` document (snake_case keys match TimeBlox-style payloads).
struct AppUserProfile: Codable, Equatable, Sendable {
    var userId: String
    var email: String?
    var isAnonymous: Bool?
    var creationDate: Date?
    var creationVersion: String?
    var lastSignInDate: Date?
    var didCompleteOnboarding: Bool?

    init(
        userId: String,
        email: String? = nil,
        isAnonymous: Bool? = nil,
        creationDate: Date? = nil,
        creationVersion: String? = nil,
        lastSignInDate: Date? = nil,
        didCompleteOnboarding: Bool? = nil
    ) {
        self.userId = userId
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.creationVersion = creationVersion
        self.lastSignInDate = lastSignInDate
        self.didCompleteOnboarding = didCompleteOnboarding
    }

    init(auth: UserAuthInfo, creationVersion: String?) {
        self.init(
            userId: auth.uid,
            email: auth.email,
            isAnonymous: auth.isAnonymous,
            creationDate: auth.creationDate,
            creationVersion: creationVersion,
            lastSignInDate: auth.lastSignInDate
        )
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case isAnonymous = "is_anonymous"
        case creationDate = "creation_date"
        case creationVersion = "creation_version"
        case lastSignInDate = "last_sign_in_date"
        case didCompleteOnboarding = "did_complete_onboarding"
    }

    static let mock = AppUserProfile(
        userId: "mock_user_1",
        isAnonymous: true,
        creationDate: Date(timeIntervalSince1970: 1_700_000_000),
        creationVersion: "1.0",
        lastSignInDate: Date(timeIntervalSince1970: 1_700_000_000),
        didCompleteOnboarding: false
    )
}

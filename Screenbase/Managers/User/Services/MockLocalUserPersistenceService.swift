//
//  MockLocalUserPersistenceService.swift
//  Screenbase
//

import Foundation

final class MockLocalUserPersistenceService: LocalUserPersistenceService, @unchecked Sendable {
    private let lock = NSLock()
    private(set) var stored: AppUserProfile?

    init(initial: AppUserProfile?) {
        stored = initial
    }

    func replace(_ user: AppUserProfile?) {
        lock.lock()
        stored = user
        lock.unlock()
    }

    func getCurrentUser() -> AppUserProfile? {
        lock.lock()
        defer { lock.unlock() }
        return stored
    }

    func saveCurrentUser(user: AppUserProfile?) throws {
        replace(user)
    }

    func clearUserData() {
        replace(nil)
    }
}

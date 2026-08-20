//
//  LocalUserPersistenceService.swift
//  Screenbase
//

import Foundation

protocol LocalUserPersistenceService {
    func getCurrentUser() -> AppUserProfile?
    func saveCurrentUser(user: AppUserProfile?) throws
    func clearUserData()
}

//
//  LocalUserPersistenceLive.swift
//  Screenbase
//

import Foundation

struct LocalUserPersistenceLive: LocalUserPersistenceService {
    private let fileName = "app_user_profile.json"

    private func directoryURL() throws -> URL {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let dir = base.appendingPathComponent("Screenbase", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private func fileURL() throws -> URL {
        try directoryURL().appendingPathComponent(fileName)
    }

    func getCurrentUser() -> AppUserProfile? {
        guard let url = try? fileURL(),
              let data = try? Data(contentsOf: url)
        else { return nil }
        return try? JSONDecoder().decode(AppUserProfile.self, from: data)
    }

    func saveCurrentUser(user: AppUserProfile?) throws {
        let url = try fileURL()
        if let user {
            let data = try JSONEncoder().encode(user)
            try data.write(to: url, options: .atomic)
        } else if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    func clearUserData() {
        guard let url = try? fileURL(), FileManager.default.fileExists(atPath: url.path) else { return }
        try? FileManager.default.removeItem(at: url)
    }
}

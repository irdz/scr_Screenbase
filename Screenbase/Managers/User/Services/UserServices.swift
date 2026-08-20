//
//  UserServices.swift
//  Screenbase
//

import Foundation

protocol UserServices {
    var remote: RemoteUserService { get }
    var local: LocalUserPersistenceService { get }
}

struct ProductionUserServices: UserServices {
    let remote: RemoteUserService
    let local: LocalUserPersistenceService

    init() {
        remote = FirebaseRemoteUserServiceLive()
        local = LocalUserPersistenceLive()
    }
}

struct MockUserServices: UserServices {
    let remote: RemoteUserService
    let local: LocalUserPersistenceService

    init(user: AppUserProfile? = nil) {
        let localMock = MockLocalUserPersistenceService(initial: user)
        remote = MockRemoteUserService(localMirror: localMock)
        local = localMock
    }
}

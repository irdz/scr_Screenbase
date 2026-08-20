//
//  UserAuthInfo+Firebase.swift
//  Screenbase
//

import FirebaseAuth

extension UserAuthInfo {
    init(user: FirebaseAuth.User) {
        uid = user.uid
        email = user.email
        isAnonymous = user.isAnonymous
        creationDate = user.metadata.creationDate
        lastSignInDate = user.metadata.lastSignInDate
    }
}

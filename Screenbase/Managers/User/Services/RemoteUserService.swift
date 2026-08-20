//
//  RemoteUserService.swift
//  Screenbase
//

import FirebaseFirestore
import Foundation

typealias FirestoreListenerRegistration = FirebaseFirestore.ListenerRegistration

protocol RemoteUserService {
    func saveUser(user: AppUserProfile) async throws
    func markOnboardingCompleted(userId: String) async throws
    func streamUser(
        userId: String,
        onListenerConfigured: @escaping @Sendable (FirestoreListenerRegistration?) -> Void
    ) -> AsyncThrowingStream<AppUserProfile, Error>
    func deleteUser(userId: String) async throws
}

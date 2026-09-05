//
//  FirestoreDocumentID.swift
//  Screenbase
//

import Foundation

enum FirestoreDocumentID {
    /// Photos `localIdentifier` values include `/` (e.g. `UUID/L0/001`). Firestore treats `/` as a
    /// path separator, so those strings cannot be used as document IDs verbatim.
    static func fromAssetLocalIdentifier(_ localIdentifier: String) -> String {
        localIdentifier.replacingOccurrences(of: "/", with: "__")
    }
}

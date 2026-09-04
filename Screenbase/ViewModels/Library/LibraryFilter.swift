//
//  LibraryFilter.swift
//  Screenbase
//

import Foundation

enum LibraryFilter: String, CaseIterable, Identifiable, Sendable {
    case all
    case collections
    case favorites
    case recent

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "All"
        case .collections: "Collections"
        case .favorites: "Favorites"
        case .recent: "Recent"
        }
    }
}

//
//  SearchView.swift
//  Screenbase
//

import PhosphorSwift
import SwiftUI

struct SearchView: View {
    @Environment(\.isSearching) private var isSearching
    var query: String = ""

    var body: some View {
        NavigationStack {
            Group {
                if isSearching {
                    if query.isEmpty {
                        ContentUnavailableView(
                            "No Recent Searches",
                            systemImage: "magnifyingglass",
                            description: Text("Your recent searches will appear here.")
                        )
                    } else {
                        ContentUnavailableView.search(text: query)
                    }
                } else {
                    VStack(spacing: 16) {
                        Ph.magnifyingGlass.bold
                            .color(ScreenbaseColors.ink)
                            .frame(width: 28, height: 28)

                        Text("Search")
                            .displayFont(size: 28)
                            .foregroundStyle(ScreenbaseColors.ink)

                        Text("Search across screenshot text, notes, tags, and collections.")
                            .font(.system(size: 16))
                            .foregroundStyle(ScreenbaseColors.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(ScreenbaseColors.background)
            .navigationTitle("Search")
            .toolbar(removing: .search)
        }
    }
}

#Preview("Landing") {
    SearchView()
}

#Preview("Query") {
    SearchView(query: "receipts")
}

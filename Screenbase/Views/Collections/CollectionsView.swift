//
//  CollectionsView.swift
//  Screenbase
//

import SwiftUI

struct CollectionsView: View {
    private let columns = [
        GridItem(.flexible(), spacing: ScreenbaseMetrics.collectionGridSpacing),
        GridItem(.flexible(), spacing: ScreenbaseMetrics.collectionGridSpacing)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: ScreenbaseMetrics.collectionGridSpacing) {
                    NewCollectionTileView()
                }
                .padding(.horizontal, ScreenbaseMetrics.edgePadding)
            }
            .screenTitle("Collections")
        }
    }
}

#Preview {
    CollectionsView()
}

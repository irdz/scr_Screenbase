//
//  NewCollectionTileView.swift
//  Screenbase
//

import PhosphorSwift
import SwiftUI

struct NewCollectionTileView: View {
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: ScreenbaseMetrics.radiusCard, style: .continuous)
                .fill(ScreenbaseColors.lightGray)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    Ph.plus.bold
                        .color(ScreenbaseColors.gray)
                        .frame(width: 32, height: 32)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("New collection")
    }
}

#Preview("Empty Tile") {
    NewCollectionTileView()
        .padding()
        .frame(width: 180)
}

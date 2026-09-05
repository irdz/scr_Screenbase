//
//  LibraryScreenshotTileView.swift
//  Screenbase
//

import SwiftUI
import UIKit

struct LibraryScreenshotTileView: View {
    var assetLocalIdentifier: String
    var isSelected: Bool = false
    var image: UIImage?
    var showsPlaceholder: Bool = false
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            tileContent
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: ScreenbaseMetrics.radiusThumbnail, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: ScreenbaseMetrics.radiusThumbnail, style: .continuous)
                        .strokeBorder(ScreenbaseColors.ink, lineWidth: isSelected ? 2 : 0)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Screenshot")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private var tileContent: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            RoundedRectangle(cornerRadius: ScreenbaseMetrics.radiusThumbnail, style: .continuous)
                .fill(ScreenbaseColors.lightGray)
                .overlay {
                    if !showsPlaceholder {
                        ProgressView()
                            .tint(ScreenbaseColors.gray)
                    }
                }
        }
    }
}

#Preview("Selected") {
    LibraryScreenshotTileView(
        assetLocalIdentifier: "mock",
        isSelected: true,
        showsPlaceholder: true
    )
    .frame(width: 120)
    .padding()
}

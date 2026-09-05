//
//  CollectionTileView.swift
//  Screenbase
//

import SwiftUI
import UIKit

struct CollectionTileView: View {
    var title: String = ""
    var subtitle: String = ""
    var previewImage: UIImage?
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    ScreenbaseColors.lightGray

                    if let previewImage {
                        Image(uiImage: previewImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(ScreenbaseFonts.display(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.top, 28)
                    .padding(.bottom, 14)
                    .background(
                        LinearGradient(
                            colors: [
                                .clear,
                                Color.black.opacity(0.55),
                                Color.black.opacity(0.82)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: ScreenbaseMetrics.radiusCard, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: ScreenbaseMetrics.radiusCard, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(subtitle)")
    }
}

#Preview("Empty") {
    CollectionTileView(title: "Ads I Love", subtitle: "0 screenshots")
        .padding()
        .frame(width: 180)
}

#Preview("Populated") {
    CollectionTileView(
        title: "Food",
        subtitle: "3 screenshots",
        previewImage: UIImage(systemName: "photo")
    )
    .padding()
    .frame(width: 180)
}

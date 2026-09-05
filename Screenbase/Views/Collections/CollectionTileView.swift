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
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    ZStack(alignment: .bottomLeading) {
                        Group {
                            if let previewImage {
                                Image(uiImage: previewImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                ScreenbaseColors.lightGray
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()

                        LinearGradient(
                            colors: [
                                .clear,
                                Color.black.opacity(0.45),
                                Color.black.opacity(0.78)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .allowsHitTesting(false)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(ScreenbaseFonts.display(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .lineLimit(2)
                            Text(subtitle)
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        .padding(14)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: ScreenbaseMetrics.radiusCard, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(subtitle)")
    }
}

#Preview {
    CollectionTileView(title: "Onboarding", subtitle: "12 screenshots")
        .padding()
        .frame(width: 180)
}

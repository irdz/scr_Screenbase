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
                    ZStack(alignment: .bottom) {
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
                .clipShape(RoundedRectangle(cornerRadius: ScreenbaseMetrics.radiusCard, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(subtitle)")
    }
}

#Preview("With count") {
    CollectionTileView(title: "Onboarding", subtitle: "12 screenshots")
        .padding()
        .frame(width: 180)
}

#Preview("Empty collection") {
    CollectionTileView(title: "Ideas", subtitle: "0 screenshots")
        .padding()
        .frame(width: 180)
}

//
//  CollectionTileView.swift
//  Screenbase
//

import PhosphorSwift
import SwiftUI

struct CollectionTileView: View {
    var title: String = ""
    var subtitle: String = ""
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: ScreenbaseMetrics.radiusCard, style: .continuous)
                .fill(ScreenbaseColors.lightGray)
                .aspectRatio(1, contentMode: .fit)
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(ScreenbaseFonts.display(size: 16, weight: .semibold))
                            .foregroundStyle(ScreenbaseColors.ink)
                            .lineLimit(2)
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundStyle(ScreenbaseColors.gray)
                    }
                    .padding(14)
                }
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

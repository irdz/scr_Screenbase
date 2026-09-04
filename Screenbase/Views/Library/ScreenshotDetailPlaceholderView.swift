//
//  ScreenshotDetailPlaceholderView.swift
//  Screenbase
//

import SwiftUI

/// Temporary destination until SCR-9 Screenshot Detail ships.
struct ScreenshotDetailPlaceholderView: View {
    var screenshot: ScreenshotRecord

    var body: some View {
        VStack(alignment: .leading, spacing: ScreenbaseMetrics.spacing * 2) {
            Text("Screenshot Detail")
                .displayFont(size: 28)
                .foregroundStyle(ScreenbaseColors.ink)

            Text(screenshot.assetLocalIdentifier)
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(ScreenbaseColors.gray)
                .textSelection(.enabled)

            if let annotation = screenshot.annotationText, !annotation.isEmpty {
                Text(annotation)
                    .font(ScreenbaseFonts.display(size: 16, weight: .regular))
                    .foregroundStyle(ScreenbaseColors.ink)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(ScreenbaseMetrics.edgePadding)
        .screenbaseBackground()
        .pushedScreen(title: "Detail")
    }
}

#Preview {
    NavigationStack {
        ScreenshotDetailPlaceholderView(screenshot: .mock)
    }
}

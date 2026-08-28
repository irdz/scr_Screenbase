//
//  ScreenTitleModifier.swift
//  Screenbase
//

import SwiftUI

struct ScreenTitleModifier: ViewModifier {
    var title: String

    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .displayFont(size: ScreenbaseMetrics.screenTitleSize)
                .foregroundStyle(ScreenbaseColors.ink)
                .padding(.horizontal, ScreenbaseMetrics.edgePadding)
                .padding(.top, ScreenbaseMetrics.spacing)
                .padding(.bottom, ScreenbaseMetrics.spacing)

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenbaseBackground()
        .toolbar(.hidden, for: .navigationBar)
    }
}

extension View {
    func screenTitle(_ title: String) -> some View {
        modifier(ScreenTitleModifier(title: title))
    }
}

#Preview("Screen Title") {
    NavigationStack {
        Text("Body")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .screenTitle("Library")
    }
}

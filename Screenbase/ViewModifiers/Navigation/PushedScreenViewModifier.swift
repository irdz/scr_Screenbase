//
//  PushedScreenViewModifier.swift
//  Screenbase
//

import SwiftUI

struct PushedScreenViewModifier: ViewModifier {
    var title: String

    func body(content: Content) -> some View {
        content
            .screenbaseBackground()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.visible, for: .navigationBar)
    }
}

extension View {
    func pushedScreen(title: String) -> some View {
        modifier(PushedScreenViewModifier(title: title))
    }
}

#Preview {
    NavigationStack {
        Text("Semantic and visual analysis runs on this device.")
            .font(.system(size: 16))
            .foregroundStyle(ScreenbaseColors.ink)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(ScreenbaseMetrics.edgePadding)
            .pushedScreen(title: "On-Device Analysis")
    }
}

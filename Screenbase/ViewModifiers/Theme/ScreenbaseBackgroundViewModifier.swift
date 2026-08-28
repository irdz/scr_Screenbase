//
//  ScreenbaseBackgroundViewModifier.swift
//  Screenbase
//

import SwiftUI

struct ScreenbaseBackgroundViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(ScreenbaseColors.background)
    }
}

extension View {
    func screenbaseBackground() -> some View {
        modifier(ScreenbaseBackgroundViewModifier())
    }
}

#Preview {
    Text("Library")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenbaseBackground()
}

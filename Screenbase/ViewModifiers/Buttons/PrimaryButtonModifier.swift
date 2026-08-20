//
//  PrimaryButtonModifier.swift
//  Screenbase
//

import SwiftUI

struct PrimaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(ScreenbaseColors.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, ScreenbaseMetrics.buttonPaddingV)
            .background(ScreenbaseColors.ink)
            .clipShape(Capsule())
    }
}

extension View {
    func primaryButtonStyle() -> some View {
        modifier(PrimaryButtonModifier())
    }
}

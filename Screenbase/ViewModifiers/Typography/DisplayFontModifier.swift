//
//  DisplayFontModifier.swift
//  Screenbase
//

import SwiftUI

struct DisplayFontModifier: ViewModifier {
    var size: CGFloat
    var weight: Font.Weight = .bold

    func body(content: Content) -> some View {
        content.font(ScreenbaseFonts.display(size: size, weight: weight))
    }
}

extension View {
    func displayFont(size: CGFloat, weight: Font.Weight = .bold) -> some View {
        modifier(DisplayFontModifier(size: size, weight: weight))
    }
}

#Preview("Display Font") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Welcome to Screenbase")
            .displayFont(size: 32)
        Text("Finding your screenshots")
            .displayFont(size: 28)
        Text("Account")
            .displayFont(size: 18)
    }
    .foregroundStyle(ScreenbaseColors.ink)
    .padding()
}

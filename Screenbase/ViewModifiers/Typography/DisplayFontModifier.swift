//
//  DisplayFontModifier.swift
//  Screenbase
//

import SwiftUI

struct DisplayFontModifier: ViewModifier {
    var size: CGFloat
    var weight: Font.Weight = .bold

    func body(content: Content) -> some View {
        content.font(.custom(ScreenbaseFonts.display, size: size, relativeTo: .largeTitle).weight(weight))
    }
}

extension View {
    func displayFont(size: CGFloat, weight: Font.Weight = .bold) -> some View {
        modifier(DisplayFontModifier(size: size, weight: weight))
    }
}

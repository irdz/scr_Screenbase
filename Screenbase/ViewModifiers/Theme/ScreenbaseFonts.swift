//
//  ScreenbaseFonts.swift
//  Screenbase
//

import CoreText
import SwiftUI
import UIKit

enum ScreenbaseFonts {
    static let family = "Nunito Sans"
    /// Default named instance registered from `NunitoSans-Variable.ttf`.
    static let romanPostScript = "NunitoSans-12ptExtraLight"
    static let italicPostScript = "NunitoSans-12ptExtraLightItalic"

    static func display(size: CGFloat, weight: Font.Weight = .bold, italic: Bool = false) -> Font {
        Font(uiFont(size: size, weight: weight, italic: italic))
    }

    static func uiFont(size: CGFloat, weight: Font.Weight = .bold, italic: Bool = false) -> UIFont {
        let postScript = italic ? italicPostScript : romanPostScript
        let base = UIFont(name: postScript, size: size)
            ?? UIFont(name: family, size: size)
            ?? .systemFont(ofSize: size, weight: .bold)

        let variationKey = UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String)
        let descriptor = base.fontDescriptor.addingAttributes([
            variationKey: [
                Self.axisTag("wght"): axisWeight(weight),
                Self.axisTag("opsz"): size
            ]
        ])
        return UIFont(descriptor: descriptor, size: size)
    }

    private static func axisWeight(_ weight: Font.Weight) -> CGFloat {
        switch weight {
        case .ultraLight, .thin: 200
        case .light: 300
        case .regular: 400
        case .medium: 500
        case .semibold: 600
        case .heavy: 800
        case .black: 900
        default: 700
        }
    }

    private static func axisTag(_ tag: String) -> Int {
        tag.utf8.reduce(0) { ($0 << 8) | Int($1) }
    }
}

#Preview("Nunito Sans") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Ideas")
            .font(ScreenbaseFonts.display(size: 32, weight: .bold))
        Text("Account")
            .font(ScreenbaseFonts.display(size: 18, weight: .bold))
        Text("Regular display")
            .font(ScreenbaseFonts.display(size: 16, weight: .regular))
    }
    .padding()
}

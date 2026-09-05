//
//  ScreenbaseColors.swift
//  Screenbase
//

import SwiftUI

/// Design tokens from PRD §24, backed by asset catalog colors with light/dark variants.
/// Asset names use a `Scr` prefix so they don't collide with system color names.
enum ScreenbaseColors {
    // MARK: Product chrome

    static let background = Color("ScrBackground")
    static let ink = Color("ScrInk")
    static let lightGray = Color("ScrLightGray")
    static let gray = Color("ScrGray")
    static let navInactive = Color("ScrNavInactive")
    static let elevated = Color("ScrElevated")
    static let line = Color("ScrLine")
    static let lineCool = Color("ScrLineCool")
    static let red = Color("ScrRed")
    static let green = Color("ScrGreen")

    // MARK: Brand / marketing (icon & marketing surfaces)

    static let navy = Color("ScrNavy")
    static let navyDeep = Color("ScrNavyDeep")
    static let navyPanel = Color("ScrNavyPanel")
    static let sky = Color("ScrSky")
    static let skyLight = Color("ScrSkyLight")
    static let amber = Color("ScrAmber")
}

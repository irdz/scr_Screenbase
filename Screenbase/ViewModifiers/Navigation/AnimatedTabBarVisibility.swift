//
//  AnimatedTabBarVisibility.swift
//  Screenbase
//

import SwiftUI

extension View {
    /// Controls tab bar visibility with an animated transition when the value changes.
    func animatedTabBarVisibility(_ visibility: Visibility) -> some View {
        toolbarVisibility(visibility, for: .tabBar)
    }
}

enum TabBarVisibilityAnimation {
    static let animation: Animation = .easeInOut(duration: 0.28)

    static func set(_ visibility: Binding<Visibility>, to newValue: Visibility) {
        withAnimation(animation) {
            visibility.wrappedValue = newValue
        }
    }
}

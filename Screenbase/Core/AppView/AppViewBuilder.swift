//
//  AppViewBuilder.swift
//  Screenbase
//

import SwiftUI

struct AppViewBuilder<MainAppView: View, OnboardingView: View>: View {
    var showMainApp: Bool
    @ViewBuilder var mainAppView: MainAppView
    @ViewBuilder var onboardingView: OnboardingView

    var body: some View {
        ZStack {
            if showMainApp {
                mainAppView
                    .transition(.move(edge: .trailing))
            } else {
                onboardingView
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.smooth, value: showMainApp)
    }
}

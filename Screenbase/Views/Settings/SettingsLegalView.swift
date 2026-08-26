//
//  SettingsLegalView.swift
//  Screenbase
//

import PhosphorSwift
import SwiftUI

struct SettingsLegalView: View {
    var body: some View {
        List {
            if let url = URL(string: Constants.privacyPolicyURL) {
                Link(destination: url) {
                    SettingsRowView(icon: .fileText, title: "Privacy Policy")
                }
                .listRowBackground(ScreenbaseColors.elevated)
            }

            if let url = URL(string: Constants.termsOfUseURL) {
                Link(destination: url) {
                    SettingsRowView(icon: .fileText, title: "Terms")
                }
                .listRowBackground(ScreenbaseColors.elevated)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(ScreenbaseColors.background)
        .navigationTitle("Privacy Policy / Terms")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .tint(ScreenbaseColors.ink)
    }
}

#Preview {
    NavigationStack {
        SettingsLegalView()
    }
}

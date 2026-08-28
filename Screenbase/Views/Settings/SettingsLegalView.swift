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
                .screenbaseListRow()
            }

            if let url = URL(string: Constants.termsOfUseURL) {
                Link(destination: url) {
                    SettingsRowView(icon: .fileText, title: "Terms")
                }
                .screenbaseListRow()
            }
        }
        .screenbaseListStyle()
        .pushedScreen(title: "Privacy Policy / Terms")
    }
}

#Preview {
    NavigationStack {
        SettingsLegalView()
    }
}

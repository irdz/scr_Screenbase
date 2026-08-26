//
//  SettingsRowView.swift
//  Screenbase
//

import PhosphorSwift
import SwiftUI

struct SettingsRowView: View {
    var icon: Ph
    var title: String
    var value: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            icon.bold
                .color(ScreenbaseColors.ink)
                .frame(width: ScreenbaseMetrics.settingsRowIconSize, height: ScreenbaseMetrics.settingsRowIconSize)

            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(ScreenbaseColors.ink)

            Spacer(minLength: 8)

            if let value {
                Text(value)
                    .font(.system(size: 15))
                    .foregroundStyle(ScreenbaseColors.gray)
                    .lineLimit(1)
            }
        }
    }
}

#Preview("Label") {
    SettingsRowView(icon: .gearSix, title: "Settings")
        .padding()
}

#Preview("Value") {
    SettingsRowView(icon: .info, title: "Version", value: "1.0 (1)")
        .padding()
}

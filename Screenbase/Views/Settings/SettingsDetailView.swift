//
//  SettingsDetailView.swift
//  Screenbase
//

import SwiftUI

struct SettingsDetailView: View {
    var title: String
    var message: String

    var body: some View {
        ScrollView {
            Text(message)
                .font(.system(size: 16))
                .foregroundStyle(ScreenbaseColors.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(ScreenbaseMetrics.edgePadding)
        }
        .pushedScreen(title: title)
    }
}

#Preview {
    NavigationStack {
        SettingsDetailView(
            title: SettingsCopy.OnDeviceAnalysis.title,
            message: SettingsCopy.OnDeviceAnalysis.message
        )
    }
}

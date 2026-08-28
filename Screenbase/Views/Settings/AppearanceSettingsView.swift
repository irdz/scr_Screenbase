//
//  AppearanceSettingsView.swift
//  Screenbase
//

import SwiftUI

struct AppearanceSettingsView: View {
    @Binding var appearance: AppearancePreference

    var body: some View {
        List {
            Picker("Appearance", selection: $appearance) {
                ForEach(AppearancePreference.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(.inline)
            .screenbaseListRow()
        }
        .screenbaseListStyle()
        .pushedScreen(title: "Appearance")
    }
}

#Preview {
    @Previewable @State var appearance = AppearancePreference.system
    NavigationStack {
        AppearanceSettingsView(appearance: $appearance)
    }
}

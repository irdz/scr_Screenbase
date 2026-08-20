//
//  SettingsView.swift
//  Screenbase
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Privacy")
                            .displayFont(size: 18)
                            .foregroundStyle(ScreenbaseColors.ink)
                        Text("Your screenshots stay on your devices. Screenbase does not upload your library.")
                            .font(.system(size: 15))
                            .foregroundStyle(ScreenbaseColors.gray)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(ScreenbaseColors.background)
                }
            }
            .scrollContentBackground(.hidden)
            .background(ScreenbaseColors.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView()
}

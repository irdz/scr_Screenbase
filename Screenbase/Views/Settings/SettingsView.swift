//
//  SettingsView.swift
//  Screenbase
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            SettingsListView(viewModel: viewModel)
                .screenTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}

//
//  SettingsListView.swift
//  Screenbase
//

import PhosphorSwift
import StoreKit
import SwiftUI

struct SettingsListView: View {
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.requestReview) private var requestReview
    @State private var isRestoreAlertPresented = false

    var body: some View {
        List {
            Section("Import") {
                Toggle(isOn: $viewModel.deleteAfterImport) {
                    SettingsRowView(icon: .trash, title: "Delete After Import")
                }

                Toggle(isOn: $viewModel.autoGroupScreenshots) {
                    SettingsRowView(icon: .stack, title: "Auto-Group Screenshots")
                }

                NavigationLink {
                    SettingsDetailView(
                        title: SettingsCopy.ImportExisting.title,
                        message: SettingsCopy.ImportExisting.message
                    )
                } label: {
                    SettingsRowView(icon: .downloadSimple, title: "Import Existing Screenshots")
                }
            }
            .listRowBackground(ScreenbaseColors.elevated)

            Section("AI & Analysis") {
                Toggle(isOn: $viewModel.automaticAnalysis) {
                    SettingsRowView(icon: .sparkle, title: "Automatic Analysis")
                }
            }
            .listRowBackground(ScreenbaseColors.elevated)

            Section("Annotations") {
                Toggle(isOn: $viewModel.showAnnotationsByDefault) {
                    SettingsRowView(icon: .eye, title: "Show Annotations by Default")
                }
            }
            .listRowBackground(ScreenbaseColors.elevated)

            Section("Search") {
                Toggle(isOn: $viewModel.includeScreenshotText) {
                    SettingsRowView(icon: .textT, title: "Include Screenshot Text")
                }

                Toggle(isOn: $viewModel.includeVisualAnalysis) {
                    SettingsRowView(icon: .image, title: "Include Visual Analysis")
                }
            }
            .listRowBackground(ScreenbaseColors.elevated)

            Section("Organization") {
                Toggle(isOn: $viewModel.autoTag) {
                    SettingsRowView(icon: .tag, title: "Auto-Tag")
                }
            }
            .listRowBackground(ScreenbaseColors.elevated)

            Section("Appearance") {
                NavigationLink {
                    AppearanceSettingsView(appearance: $viewModel.appearance)
                } label: {
                    SettingsRowView(
                        icon: .circleHalf,
                        title: "Appearance",
                        value: viewModel.appearance.title
                    )
                }
            }
            .listRowBackground(ScreenbaseColors.elevated)

            Section("Storage") {
                SettingsRowView(icon: .hardDrives, title: "Storage Used", value: viewModel.storageUsedDisplay)
            }
            .listRowBackground(ScreenbaseColors.elevated)

            Section("Privacy") {
                NavigationLink {
                    SettingsDetailView(
                        title: SettingsCopy.OnDeviceAnalysis.title,
                        message: SettingsCopy.OnDeviceAnalysis.message
                    )
                } label: {
                    SettingsRowView(icon: .cpu, title: "On-Device Analysis")
                }

                Toggle(isOn: $viewModel.analyticsEnabled) {
                    SettingsRowView(icon: .chartBar, title: "Analytics")
                }

                NavigationLink {
                    SettingsDetailView(
                        title: SettingsCopy.AIProcessing.title,
                        message: SettingsCopy.AIProcessing.message
                    )
                } label: {
                    SettingsRowView(icon: .brain, title: "AI Processing")
                }
            }
            .listRowBackground(ScreenbaseColors.elevated)

            Section("General") {
                NavigationLink {
                    SettingsDetailView(
                        title: SettingsCopy.ShareExtension.title,
                        message: SettingsCopy.ShareExtension.message
                    )
                } label: {
                    SettingsRowView(icon: .export, title: "Share Extension")
                }
            }
            .listRowBackground(ScreenbaseColors.elevated)

            Section("Account") {
                NavigationLink {
                    SettingsDetailView(
                        title: SettingsCopy.ScreenbasePro.title,
                        message: """
                        Status: \(viewModel.subscriptionStatus)

                        \(SettingsCopy.ScreenbasePro.message)
                        """
                    )
                } label: {
                    SettingsRowView(
                        icon: .crown,
                        title: "Screenbase Pro",
                        value: viewModel.subscriptionStatus
                    )
                }

                Button {
                    isRestoreAlertPresented = true
                } label: {
                    SettingsRowView(icon: .arrowClockwise, title: "Restore Purchases")
                }
            }
            .listRowBackground(ScreenbaseColors.elevated)

            Section("About") {
                NavigationLink {
                    SettingsDetailView(
                        title: SettingsCopy.WhatsNew.title,
                        message: SettingsCopy.WhatsNew.message
                    )
                } label: {
                    SettingsRowView(icon: .megaphone, title: "What’s New")
                }

                if let url = URL(string: "mailto:\(Constants.feedbackEmail)") {
                    Link(destination: url) {
                        SettingsRowView(icon: .paperPlaneTilt, title: "Send Feedback")
                    }
                }

                Button {
                    requestReview()
                } label: {
                    SettingsRowView(icon: .star, title: "Rate Screenbase")
                }

                NavigationLink {
                    SettingsLegalView()
                } label: {
                    SettingsRowView(icon: .fileText, title: "Privacy Policy / Terms")
                }

                SettingsRowView(icon: .info, title: "Version", value: viewModel.versionDisplay)
            }
            .listRowBackground(ScreenbaseColors.elevated)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .tint(ScreenbaseColors.ink)
        .alert("Restore Purchases", isPresented: $isRestoreAlertPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("No purchases to restore.")
        }
    }
}

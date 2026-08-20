//
//  MainTabView.swift
//  Screenbase
//

import PhosphorSwift
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Destination = .library

    enum Destination: Hashable {
        case library
        case search
        case collections
        case settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: .library) {
                LibraryView()
            } label: {
                Label {
                    Text("Library")
                } icon: {
                    Ph.squaresFour.tabBarBold
                }
            }

            Tab(value: .search) {
                SearchView()
            } label: {
                Label {
                    Text("Search")
                } icon: {
                    Ph.magnifyingGlass.tabBarBold
                }
            }

            Tab(value: .collections) {
                CollectionsView()
            } label: {
                Label {
                    Text("Collections")
                } icon: {
                    Ph.folderSimple.tabBarBold
                }
            }

            Tab(value: .settings) {
                SettingsView()
            } label: {
                Label {
                    Text("Settings")
                } icon: {
                    Ph.gearSix.tabBarBold
                }
            }
        }
        .tint(ScreenbaseColors.ink)
    }
}

#Preview {
    MainTabView()
        .environment(AuthManager(service: AuthServiceMock()))
        .environment(UserManager(services: MockUserServices()))
        .environment(PhotosManager(service: MockPhotosService(status: .authorized, screenshotCount: 24)))
}

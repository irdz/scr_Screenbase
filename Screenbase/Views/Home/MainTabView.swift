//
//  MainTabView.swift
//  Screenbase
//

import PhosphorSwift
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Destination = .library
    @State private var searchText = ""

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
                    Ph.squaresFour.tabBarImage(isSelected: selectedTab == .library)
                }
            }

            Tab(value: .collections) {
                CollectionsView()
            } label: {
                Label {
                    Text("Collections")
                } icon: {
                    Ph.folderSimple.tabBarImage(isSelected: selectedTab == .collections)
                }
            }

            Tab(value: .settings) {
                SettingsView()
            } label: {
                Label {
                    Text("Settings")
                } icon: {
                    Ph.gearSix.tabBarImage(isSelected: selectedTab == .settings)
                }
            }

            Tab(value: .search, role: .search) {
                SearchView(query: searchText)
                    .searchable(text: $searchText, prompt: "Screenbase")
            } label: {
                Label {
                    Text("Search")
                } icon: {
                    Ph.magnifyingGlass.tabBarImage(isSelected: selectedTab == .search)
                }
            }
        }
        .tint(ScreenbaseColors.ink)
    }
}

#Preview {
    MainTabView()
        .environment(AppState(showMainApp: true))
        .environment(AuthManager(service: AuthServiceMock()))
        .environment(UserManager(services: MockUserServices()))
        .environment(PhotosManager(service: MockPhotosService(status: .authorized, screenshotCount: 24)))
        .environment(PurchaseManager(service: MockPurchaseService()))
}

//
//  MainTabView.swift
//  Screenbase
//

import PhosphorSwift
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            LibraryView()
                .tabItem {
                    Ph.squaresFour.bold
                        .frame(width: 24, height: 24)
                    Text("Library")
                }

            SearchView()
                .tabItem {
                    Ph.magnifyingGlass.bold
                        .frame(width: 24, height: 24)
                    Text("Search")
                }

            CollectionsView()
                .tabItem {
                    Ph.folderSimple.bold
                        .frame(width: 24, height: 24)
                    Text("Collections")
                }

            SettingsView()
                .tabItem {
                    Ph.gearSix.bold
                        .frame(width: 24, height: 24)
                    Text("Settings")
                }
        }
        .tint(ScreenbaseColors.ink)
    }
}

#Preview {
    MainTabView()
}

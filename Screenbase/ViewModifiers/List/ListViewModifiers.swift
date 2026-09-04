//
//  ListViewModifiers.swift
//  Screenbase
//

import SwiftUI

struct ScreenbaseListStyleViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .screenbaseBackground()
            .tint(ScreenbaseColors.ink)
    }
}

struct ScreenbaseListRowViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.listRowBackground(ScreenbaseColors.elevated)
    }
}

extension View {
    func screenbaseListStyle() -> some View {
        modifier(ScreenbaseListStyleViewModifier())
    }

    func screenbaseListRow() -> some View {
        modifier(ScreenbaseListRowViewModifier())
    }
}

#Preview("List Style") {
    List {
        Text("Delete After Import")
            .screenbaseListRow()
        Text("Auto-Group Screenshots")
            .screenbaseListRow()
    }
    .screenbaseListStyle()
}

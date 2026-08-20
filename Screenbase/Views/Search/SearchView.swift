//
//  SearchView.swift
//  Screenbase
//

import PhosphorSwift
import SwiftUI

struct SearchView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Ph.magnifyingGlass.bold
                    .color(ScreenbaseColors.ink)
                    .frame(width: 28, height: 28)

                Text("Search")
                    .displayFont(size: 28)
                    .foregroundStyle(ScreenbaseColors.ink)

                Text("Search across screenshot text, notes, tags, and collections.")
                    .font(.system(size: 16))
                    .foregroundStyle(ScreenbaseColors.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ScreenbaseColors.background)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SearchView()
}

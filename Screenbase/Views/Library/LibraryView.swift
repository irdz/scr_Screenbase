//
//  LibraryView.swift
//  Screenbase
//

import PhosphorSwift
import SwiftUI

struct LibraryView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Ph.images.bold
                    .color(ScreenbaseColors.ink)
                    .frame(width: 28, height: 28)

                Text("Library")
                    .displayFont(size: 28)
                    .foregroundStyle(ScreenbaseColors.ink)

                Text("Screenshots from Photos will show up here.")
                    .font(.system(size: 16))
                    .foregroundStyle(ScreenbaseColors.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ScreenbaseColors.background)
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    LibraryView()
}

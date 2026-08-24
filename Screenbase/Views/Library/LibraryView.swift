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
                    .frame(width: ScreenbaseMetrics.emptyStateIconSize, height: ScreenbaseMetrics.emptyStateIconSize)

                Text("Screenshots from Photos will show up here.")
                    .font(.system(size: 16))
                    .foregroundStyle(ScreenbaseColors.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .screenTitle("Library")
        }
    }
}

#Preview {
    LibraryView()
}

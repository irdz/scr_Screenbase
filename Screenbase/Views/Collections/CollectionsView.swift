//
//  CollectionsView.swift
//  Screenbase
//

import PhosphorSwift
import SwiftUI

struct CollectionsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Ph.folderSimple.bold
                    .color(ScreenbaseColors.ink)
                    .frame(width: 28, height: 28)

                Text("Collections")
                    .displayFont(size: 28)
                    .foregroundStyle(ScreenbaseColors.ink)

                Text("Group screenshots into lightweight collections.")
                    .font(.system(size: 16))
                    .foregroundStyle(ScreenbaseColors.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ScreenbaseColors.background)
            .navigationTitle("Collections")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CollectionsView()
}

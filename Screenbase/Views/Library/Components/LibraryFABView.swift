//
//  LibraryFABView.swift
//  Screenbase
//

import PhosphorSwift
import SwiftUI

struct LibraryFABView: View {
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            Ph.plus.bold
                .color(ScreenbaseColors.background)
                .frame(width: 24, height: 24)
                .frame(width: 56, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(ScreenbaseColors.ink)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add screenshots")
    }
}

#Preview {
    LibraryFABView()
        .padding()
}

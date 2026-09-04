//
//  LibraryAddSourceSheet.swift
//  Screenbase
//

import PhosphorSwift
import SwiftUI

enum LibraryAddSource: String, Identifiable, CaseIterable {
    case camera
    case gallery
    case screenshotPicker

    var id: String { rawValue }

    var title: String {
        switch self {
        case .camera: "Camera"
        case .gallery: "Gallery"
        case .screenshotPicker: "Screenshot picker"
        }
    }
}

struct LibraryAddSourceSheet: View {
    var onSelect: (LibraryAddSource) -> Void = { _ in }

    var body: some View {
        NavigationStack {
            List {
                ForEach(LibraryAddSource.allCases) { source in
                    Button {
                        onSelect(source)
                    } label: {
                        HStack(spacing: 12) {
                            icon(for: source)
                            Text(source.title)
                                .font(ScreenbaseFonts.display(size: 16, weight: .semibold))
                                .foregroundStyle(ScreenbaseColors.ink)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .screenbaseListRow()
                }
            }
            .screenbaseListStyle()
            .navigationTitle("Add")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }

    @ViewBuilder
    private func icon(for source: LibraryAddSource) -> some View {
        Group {
            switch source {
            case .camera:
                Ph.camera.bold
            case .gallery:
                Ph.images.bold
            case .screenshotPicker:
                Ph.imageSquare.bold
            }
        }
        .color(ScreenbaseColors.ink)
        .frame(width: 24, height: 24)
    }
}

#Preview {
    LibraryAddSourceSheet()
}

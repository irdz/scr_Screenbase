//
//  LibraryFilterChipRowView.swift
//  Screenbase
//

import SwiftUI

struct LibraryFilterChipRowView: View {
    var selectedFilter: LibraryFilter
    var onSelect: (LibraryFilter) -> Void = { _ in }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ScreenbaseMetrics.spacing) {
                ForEach(LibraryFilter.allCases) { filter in
                    Button {
                        HapticsManager.instance.lightImpact()
                        onSelect(filter)
                    } label: {
                        Text(filter.title)
                            .font(ScreenbaseFonts.display(size: 14, weight: .semibold))
                            .foregroundStyle(filter == selectedFilter ? ScreenbaseColors.background : ScreenbaseColors
                                .ink)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(filter == selectedFilter ? ScreenbaseColors.ink : ScreenbaseColors.lightGray)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(filter == selectedFilter ? .isSelected : [])
                }
            }
            .padding(.horizontal, ScreenbaseMetrics.edgePadding)
        }
    }
}

#Preview {
    LibraryFilterChipRowView(selectedFilter: .all)
}

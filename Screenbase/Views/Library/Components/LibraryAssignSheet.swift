//
//  LibraryAssignSheet.swift
//  Screenbase
//

import PhosphorSwift
import SwiftUI

struct LibraryAssignSheet: View {
    var title: String = "Assign"
    var collections: [CollectionRecord] = []
    var tags: [TagRecord] = []
    var selectedCollectionIds: Set<String> = []
    var selectedTagIds: Set<String> = []
    var showsCollections: Bool = true
    var showsTags: Bool = true
    var canApply: Bool = false
    var onToggleCollection: (String) -> Void = { _ in }
    var onToggleTag: (String) -> Void = { _ in }
    var onCreateCollection: () -> Void = {}
    var onCreateTag: () -> Void = {}
    var onApply: () -> Void = {}
    var onCancel: () -> Void = {}

    var body: some View {
        NavigationStack {
            List {
                if showsCollections {
                    Section("Collections") {
                        Button {
                            onCreateCollection()
                        } label: {
                            Label("New Collection", systemImage: "plus")
                                .font(ScreenbaseFonts.display(size: 16, weight: .semibold))
                                .foregroundStyle(ScreenbaseColors.ink)
                        }
                        .screenbaseListRow()

                        ForEach(collections) { collection in
                            assignRow(
                                title: collection.name,
                                isSelected: selectedCollectionIds.contains(collection.id)
                            ) {
                                onToggleCollection(collection.id)
                            }
                        }
                    }
                }

                if showsTags {
                    Section("Tags") {
                        Button {
                            onCreateTag()
                        } label: {
                            Label("New Tag", systemImage: "plus")
                                .font(ScreenbaseFonts.display(size: 16, weight: .semibold))
                                .foregroundStyle(ScreenbaseColors.ink)
                        }
                        .screenbaseListRow()

                        ForEach(tags) { tag in
                            assignRow(
                                title: tag.name,
                                isSelected: selectedTagIds.contains(tag.id)
                            ) {
                                onToggleTag(tag.id)
                            }
                        }
                    }
                }
            }
            .screenbaseListStyle()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply", action: onApply)
                        .disabled(!canApply)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func assignRow(
        title: String,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Text(title)
                    .font(ScreenbaseFonts.display(size: 16, weight: .semibold))
                    .foregroundStyle(ScreenbaseColors.ink)
                Spacer()
                if isSelected {
                    Ph.checkCircle.bold
                        .color(ScreenbaseColors.ink)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.vertical, 4)
        }
        .screenbaseListRow()
    }
}

#Preview {
    LibraryAssignSheet(
        collections: [.mock],
        tags: [.mock],
        selectedCollectionIds: ["col_1"],
        canApply: true
    )
}

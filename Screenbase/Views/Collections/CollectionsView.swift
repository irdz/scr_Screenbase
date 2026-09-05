//
//  CollectionsView.swift
//  Screenbase
//

import PhosphorSwift
import SwiftUI

struct CollectionsView: View {
    @Environment(MetadataManager.self) private var metadataManager
    @Environment(PhotosManager.self) private var photosManager
    @Environment(\.displayScale) private var displayScale

    @State private var viewModel: CollectionsViewModel?
    @State private var thumbnailLoader: LibraryThumbnailLoader?

    private let columns = [
        GridItem(.flexible(), spacing: ScreenbaseMetrics.collectionGridSpacing),
        GridItem(.flexible(), spacing: ScreenbaseMetrics.collectionGridSpacing)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel, let thumbnailLoader {
                    content(viewModel: viewModel, thumbnailLoader: thumbnailLoader)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .screenTitle("Collections")
        }
        .onAppear {
            if viewModel == nil {
                viewModel = CollectionsViewModel(metadataManager: metadataManager)
            }
            if thumbnailLoader == nil {
                thumbnailLoader = LibraryThumbnailLoader(
                    photosManager: photosManager,
                    pointSize: 220,
                    scale: displayScale
                )
            }
        }
    }

    private func content(
        viewModel: CollectionsViewModel,
        thumbnailLoader: LibraryThumbnailLoader
    ) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ScreenbaseMetrics.spacing * 2) {
                collectionsSection(viewModel: viewModel, thumbnailLoader: thumbnailLoader)
                tagsSection(viewModel: viewModel)
            }
            .padding(.horizontal, ScreenbaseMetrics.edgePadding)
            .padding(.bottom, ScreenbaseMetrics.edgePadding)
        }
        .sheet(
            isPresented: Binding(
                get: { viewModel.isNameEditorPresented },
                set: { viewModel.isNameEditorPresented = $0 }
            )
        ) {
            CollectionNameSheet(
                title: viewModel.nameEditorTitle,
                saveTitle: viewModel.nameEditorSaveTitle,
                name: Binding(
                    get: { viewModel.nameDraft },
                    set: { viewModel.nameDraft = $0 }
                ),
                canSave: viewModel.canSaveName,
                onSave: {
                    Task { await viewModel.saveNameEditor() }
                },
                onCancel: {
                    viewModel.isNameEditorPresented = false
                }
            )
        }
        .alert(
            "Delete collection?",
            isPresented: Binding(
                get: { viewModel.pendingDeleteCollectionId != nil },
                set: { if !$0 { viewModel.pendingDeleteCollectionId = nil } }
            )
        ) {
            Button("Delete", role: .destructive) {
                Task { await viewModel.deletePendingCollection() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Screenshots stay in your library. This only removes the collection.")
        }
        .alert(
            "Delete tag?",
            isPresented: Binding(
                get: { viewModel.pendingDeleteTagId != nil },
                set: { if !$0 { viewModel.pendingDeleteTagId = nil } }
            )
        ) {
            Button("Delete", role: .destructive) {
                Task { await viewModel.deletePendingTag() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Screenshots stay in your library. This only removes the tag.")
        }
    }

    private func collectionsSection(
        viewModel: CollectionsViewModel,
        thumbnailLoader: LibraryThumbnailLoader
    ) -> some View {
        VStack(alignment: .leading, spacing: ScreenbaseMetrics.spacing) {
            Text("Your collections")
                .font(ScreenbaseFonts.display(size: 18, weight: .semibold))
                .foregroundStyle(ScreenbaseColors.ink)

            LazyVGrid(columns: columns, spacing: ScreenbaseMetrics.collectionGridSpacing) {
                NewCollectionTileView {
                    viewModel.presentCreateCollection()
                }
                .frame(maxWidth: .infinity)

                ForEach(viewModel.collections) { collection in
                    let previewAsset = viewModel.latestScreenshot(inCollection: collection.id)?
                        .assetLocalIdentifier
                    CollectionTileView(
                        title: collection.name,
                        subtitle: screenshotLabel(viewModel.screenshotCount(for: collection.id)),
                        previewImage: previewAsset.flatMap { thumbnailLoader.image(for: $0) }
                    )
                    .frame(maxWidth: .infinity)
                    .contextMenu {
                        Button("Rename") {
                            viewModel.presentRenameCollection(collection)
                        }
                        Button("Delete", role: .destructive) {
                            viewModel.confirmDeleteCollection(collection)
                        }
                    }
                    .onAppear {
                        if let previewAsset {
                            thumbnailLoader.loadIfNeeded(assetLocalIdentifier: previewAsset)
                        }
                    }
                }
            }
        }
    }

    private func tagsSection(viewModel: CollectionsViewModel) -> some View {
        VStack(alignment: .leading, spacing: ScreenbaseMetrics.spacing) {
            HStack {
                Text("Tags")
                    .font(ScreenbaseFonts.display(size: 18, weight: .semibold))
                    .foregroundStyle(ScreenbaseColors.ink)
                Spacer()
                Button {
                    viewModel.presentCreateTag()
                } label: {
                    Label("New Tag", systemImage: "plus")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(ScreenbaseColors.ink)
            }

            if viewModel.tags.isEmpty {
                Text("Create tags to organize screenshots across collections.")
                    .font(.system(size: 14))
                    .foregroundStyle(ScreenbaseColors.gray)
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.tags) { tag in
                        HStack(spacing: 12) {
                            Ph.tag.bold
                                .color(ScreenbaseColors.ink)
                                .frame(width: 20, height: 20)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tag.name)
                                    .font(ScreenbaseFonts.display(size: 16, weight: .semibold))
                                    .foregroundStyle(ScreenbaseColors.ink)
                                Text(screenshotLabel(viewModel.screenshotCount(forTag: tag.id)))
                                    .font(.system(size: 13))
                                    .foregroundStyle(ScreenbaseColors.gray)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                        .contextMenu {
                            Button("Rename") {
                                viewModel.presentRenameTag(tag)
                            }
                            Button("Delete", role: .destructive) {
                                viewModel.confirmDeleteTag(tag)
                            }
                        }

                        if tag.id != viewModel.tags.last?.id {
                            Divider()
                                .overlay(ScreenbaseColors.line)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: ScreenbaseMetrics.radiusCard, style: .continuous)
                        .fill(ScreenbaseColors.lightGray)
                )
            }
        }
    }

    private func screenshotLabel(_ count: Int) -> String {
        let noun = count == 1 ? "screenshot" : "screenshots"
        return "\(count) \(noun)"
    }
}

#Preview {
    let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
    CollectionsView()
        .environment(metadata)
        .environment(PhotosManager(service: MockPhotosService(status: .authorized, screenshotCount: 4)))
        .task {
            _ = try? await metadata.createCollection(name: "Onboarding")
            _ = try? await metadata.createTag(name: "bug")
        }
}

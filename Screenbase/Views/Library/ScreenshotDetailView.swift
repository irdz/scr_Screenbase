//
//  ScreenshotDetailView.swift
//  Screenbase
//

import PhosphorSwift
import SwiftUI
import UIKit

struct ScreenshotDetailView: View {
    @Environment(MetadataManager.self) private var metadataManager
    @Environment(PhotosManager.self) private var photosManager
    @Environment(\.displayScale) private var displayScale

    let screenshotId: String

    @State private var viewModel: ScreenshotDetailViewModel?

    var body: some View {
        Group {
            if let viewModel {
                detailContent(viewModel: viewModel)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .screenbaseBackground()
        .pushedScreen(title: "Detail")
        .onAppear {
            if viewModel == nil {
                let screen = UIScreen.main.bounds.size
                viewModel = ScreenshotDetailViewModel(
                    screenshotId: screenshotId,
                    metadataManager: metadataManager,
                    photosManager: photosManager,
                    imageTargetSize: CGSize(
                        width: screen.width * displayScale,
                        height: screen.height * displayScale
                    )
                )
            }
        }
        .task(id: screenshotId) {
            await viewModel?.loadImageIfNeeded()
        }
    }

    @ViewBuilder
    private func detailContent(viewModel: ScreenshotDetailViewModel) -> some View {
        if viewModel.screenshot == nil {
            Text("Screenshot unavailable")
                .font(.system(size: 16))
                .foregroundStyle(ScreenbaseColors.gray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: ScreenbaseMetrics.spacing * 2) {
                    imageSection(viewModel: viewModel)
                    annotationSection(viewModel: viewModel)
                    membershipSection(viewModel: viewModel)
                }
                .padding(.horizontal, ScreenbaseMetrics.edgePadding)
                .padding(.bottom, ScreenbaseMetrics.edgePadding)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.presentShare()
                    } label: {
                        Ph.shareNetwork.bold
                            .color(viewModel.canShare ? ScreenbaseColors.ink : ScreenbaseColors.gray)
                            .frame(width: 22, height: 22)
                    }
                    .disabled(!viewModel.canShare)
                    .accessibilityLabel("Share")
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel.isAnnotationEditorPresented },
                set: { viewModel.isAnnotationEditorPresented = $0 }
            )) {
                annotationEditor(viewModel: viewModel)
            }
            .sheet(isPresented: Binding(
                get: { viewModel.isMembershipSheetPresented },
                set: { viewModel.isMembershipSheetPresented = $0 }
            )) {
                LibraryAssignSheet(
                    title: "Organize",
                    collections: viewModel.allCollections,
                    tags: viewModel.allTags,
                    selectedCollectionIds: viewModel.selectedCollectionIds,
                    selectedTagIds: viewModel.selectedTagIds,
                    canApply: true,
                    onToggleCollection: viewModel.toggleMembershipCollection,
                    onToggleTag: viewModel.toggleMembershipTag,
                    onCreateCollection: viewModel.presentCreateMembershipCollection,
                    onCreateTag: viewModel.presentCreateMembershipTag,
                    onApply: {
                        Task { await viewModel.applyMemberships() }
                    },
                    onCancel: {
                        viewModel.isMembershipSheetPresented = false
                    }
                )
                .alert(
                    viewModel.membershipNameEditorTitle,
                    isPresented: Binding(
                        get: { viewModel.isMembershipNameEditorPresented },
                        set: { viewModel.isMembershipNameEditorPresented = $0 }
                    )
                ) {
                    TextField("Name", text: Binding(
                        get: { viewModel.membershipNameDraft },
                        set: { viewModel.membershipNameDraft = $0 }
                    ))
                    Button("Save") {
                        Task { await viewModel.saveMembershipNameEditor() }
                    }
                    .disabled(!viewModel.canSaveMembershipName)
                    Button("Cancel", role: .cancel) {}
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel.isSharePresented },
                set: { viewModel.isSharePresented = $0 }
            )) {
                if let image = viewModel.image {
                    ShareActivityView(activityItems: [image])
                        .presentationDetents([.medium, .large])
                }
            }
        }
    }

    @ViewBuilder
    private func imageSection(viewModel: ScreenshotDetailViewModel) -> some View {
        Group {
            switch viewModel.imageState {
            case .loading:
                RoundedRectangle(cornerRadius: ScreenbaseMetrics.radiusCard, style: .continuous)
                    .fill(ScreenbaseColors.lightGray)
                    .aspectRatio(3 / 4, contentMode: .fit)
                    .overlay { ProgressView() }
            case .missing:
                missingAssetPlaceholder
            case .loaded:
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: ScreenbaseMetrics.radiusCard, style: .continuous))
                } else {
                    missingAssetPlaceholder
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var missingAssetPlaceholder: some View {
        VStack(spacing: 12) {
            Ph.imageBroken.bold
                .color(ScreenbaseColors.gray)
                .frame(width: 40, height: 40)
            Text("Photo unavailable")
                .font(ScreenbaseFonts.display(size: 16, weight: .semibold))
                .foregroundStyle(ScreenbaseColors.ink)
            Text("This screenshot was removed from Photos. Your note, tags, and collections are still saved.")
                .font(.system(size: 14))
                .foregroundStyle(ScreenbaseColors.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .background(
            RoundedRectangle(cornerRadius: ScreenbaseMetrics.radiusCard, style: .continuous)
                .fill(ScreenbaseColors.lightGray)
        )
    }

    private func annotationSection(viewModel: ScreenshotDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: ScreenbaseMetrics.spacing) {
            HStack {
                Text("Note")
                    .font(ScreenbaseFonts.display(size: 18, weight: .semibold))
                    .foregroundStyle(ScreenbaseColors.ink)
                Spacer()
                Button("Edit") {
                    viewModel.presentAnnotationEditor()
                }
                .font(ScreenbaseFonts.display(size: 15, weight: .semibold))
                .foregroundStyle(ScreenbaseColors.ink)
            }

            Button {
                viewModel.presentAnnotationEditor()
            } label: {
                Text(viewModel.annotationDisplayText)
                    .font(ScreenbaseFonts.display(size: 16, weight: .regular))
                    .foregroundStyle(viewModel.hasAnnotation ? ScreenbaseColors.ink : ScreenbaseColors.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: ScreenbaseMetrics.radiusCard, style: .continuous)
                            .fill(ScreenbaseColors.lightGray)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private func membershipSection(viewModel: ScreenshotDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: ScreenbaseMetrics.spacing) {
            HStack {
                Text("Organize")
                    .font(ScreenbaseFonts.display(size: 18, weight: .semibold))
                    .foregroundStyle(ScreenbaseColors.ink)
                Spacer()
                Button("Manage") {
                    viewModel.presentMembershipSheet()
                }
                .font(ScreenbaseFonts.display(size: 15, weight: .semibold))
                .foregroundStyle(ScreenbaseColors.ink)
            }

            if viewModel.assignedCollections.isEmpty, viewModel.assignedTags.isEmpty {
                Text("No collections or tags yet.")
                    .font(.system(size: 14))
                    .foregroundStyle(ScreenbaseColors.gray)
            } else {
                if !viewModel.assignedCollections.isEmpty {
                    chipBlock(title: "Collections", names: viewModel.assignedCollections.map(\.name))
                }
                if !viewModel.assignedTags.isEmpty {
                    chipBlock(title: "Tags", names: viewModel.assignedTags.map(\.name))
                }
            }
        }
    }

    private func chipBlock(title: String, names: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(ScreenbaseColors.gray)
            FlowChipRow(names: names)
        }
    }

    private func annotationEditor(viewModel: ScreenshotDetailViewModel) -> some View {
        NavigationStack {
            TextEditor(text: Binding(
                get: { viewModel.annotationDraft },
                set: { viewModel.annotationDraft = $0 }
            ))
            .font(ScreenbaseFonts.display(size: 17, weight: .regular))
            .padding(ScreenbaseMetrics.edgePadding)
            .navigationTitle("Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.isAnnotationEditorPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await viewModel.saveAnnotation() }
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

/// Simple wrapping chip row for collection/tag names.
private struct FlowChipRow: View {
    var names: [String]

    var body: some View {
        FlexibleChipLayout(spacing: 8) {
            ForEach(names, id: \.self) { name in
                Text(name)
                    .font(ScreenbaseFonts.display(size: 14, weight: .semibold))
                    .foregroundStyle(ScreenbaseColors.ink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule(style: .continuous)
                            .fill(ScreenbaseColors.lightGray)
                    )
            }
        }
    }
}

/// Lightweight wrap layout so chips flow without a third-party dependency.
private struct FlexibleChipLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var height: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            height = max(height, y + rowHeight)
        }
        return CGSize(width: maxWidth.isFinite ? maxWidth : x, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(size)
            )
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview("Loaded") {
    let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
    NavigationStack {
        ScreenshotDetailView(screenshotId: ScreenshotRecord.mock.id)
    }
    .environment(metadata)
    .environment(PhotosManager(service: MockPhotosService(
        status: .authorized,
        fullImages: [ScreenshotRecord.mock.assetLocalIdentifier: UIImage(systemName: "photo")!]
    )))
    .task {
        try? await metadata.upsertScreenshot(.mock)
        _ = try? await metadata.createCollection(name: "Onboarding")
        _ = try? await metadata.createTag(name: "bug")
    }
}

#Preview("Missing asset") {
    let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
    NavigationStack {
        ScreenshotDetailView(screenshotId: ScreenshotRecord.mock.id)
    }
    .environment(metadata)
    .environment(PhotosManager(service: MockPhotosService(
        status: .authorized,
        missingAssetIdentifiers: [ScreenshotRecord.mock.assetLocalIdentifier]
    )))
    .task {
        try? await metadata.upsertScreenshot(.mock)
    }
}

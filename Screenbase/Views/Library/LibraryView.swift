//
//  LibraryView.swift
//  Screenbase
//

import PhosphorSwift
import SwiftUI

struct LibraryView: View {
    @Environment(MetadataManager.self) private var metadataManager
    @Environment(ScreenshotManager.self) private var screenshotManager
    @Environment(PhotosManager.self) private var photosManager

    @State private var viewModel: LibraryViewModel?
    @State private var thumbnailLoader: LibraryThumbnailLoader?
    @State private var navigationPath = NavigationPath()

    private let columns = [
        GridItem(.flexible(), spacing: ScreenbaseMetrics.collectionGridSpacing),
        GridItem(.flexible(), spacing: ScreenbaseMetrics.collectionGridSpacing),
        GridItem(.flexible(), spacing: ScreenbaseMetrics.collectionGridSpacing)
    ]

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if let viewModel, let thumbnailLoader {
                    libraryContent(viewModel: viewModel, thumbnailLoader: thumbnailLoader)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .screenbaseBackground()
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: String.self) { screenshotId in
                if let screenshot = metadataManager.screenshots.first(where: { $0.id == screenshotId }) {
                    ScreenshotDetailPlaceholderView(screenshot: screenshot)
                } else {
                    Text("Screenshot unavailable")
                        .foregroundStyle(ScreenbaseColors.gray)
                        .pushedScreen(title: "Detail")
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = LibraryViewModel(
                    metadataManager: metadataManager,
                    screenshotManager: screenshotManager
                )
            }
            if thumbnailLoader == nil {
                thumbnailLoader = LibraryThumbnailLoader(photosManager: photosManager)
            }
        }
        .onChange(of: viewModel?.detailScreenshotId) { _, newValue in
            guard let newValue else { return }
            navigationPath.append(newValue)
            viewModel?.clearDetail()
        }
    }

    private func libraryContent(
        viewModel: LibraryViewModel,
        thumbnailLoader: LibraryThumbnailLoader
    ) -> some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                header(viewModel: viewModel)

                LibraryFilterChipRowView(selectedFilter: viewModel.selectedFilter) { filter in
                    viewModel.selectFilter(filter)
                }
                .padding(.bottom, ScreenbaseMetrics.spacing)

                content(for: viewModel, thumbnailLoader: thumbnailLoader)
            }

            LibraryFABView {
                viewModel.presentAddSheet()
            }
            .padding(.trailing, ScreenbaseMetrics.edgePadding)
            .padding(.bottom, ScreenbaseMetrics.edgePadding)
        }
        .sheet(isPresented: Binding(
            get: { viewModel.isAddSheetPresented },
            set: { viewModel.isAddSheetPresented = $0 }
        )) {
            LibraryAddSourceSheet { source in
                viewModel.isAddSheetPresented = false
                handleAddSource(source)
            }
        }
    }

    private func header(viewModel: LibraryViewModel) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Library")
                .displayFont(size: ScreenbaseMetrics.screenTitleSize)
                .foregroundStyle(ScreenbaseColors.ink)

            Spacer()

            Button(viewModel.isSelecting ? "Done" : "Select") {
                viewModel.toggleSelecting()
            }
            .font(ScreenbaseFonts.display(size: 16, weight: .semibold))
            .foregroundStyle(ScreenbaseColors.ink)
        }
        .padding(.horizontal, ScreenbaseMetrics.edgePadding)
        .padding(.top, ScreenbaseMetrics.spacing)
        .padding(.bottom, ScreenbaseMetrics.spacing)
    }

    @ViewBuilder
    private func content(
        for viewModel: LibraryViewModel,
        thumbnailLoader: LibraryThumbnailLoader
    ) -> some View {
        switch viewModel.contentState {
        case .loading:
            grid(
                items: placeholderIds(count: viewModel.skeletonTileCount),
                viewModel: viewModel,
                thumbnailLoader: thumbnailLoader,
                isSkeleton: true
            )
        case .empty:
            emptyState(for: viewModel.selectedFilter)
        case .populated:
            grid(
                items: viewModel.filteredScreenshots.map(\.id),
                viewModel: viewModel,
                thumbnailLoader: thumbnailLoader,
                isSkeleton: false
            )
        }
    }

    private func grid(
        items: [String],
        viewModel: LibraryViewModel,
        thumbnailLoader: LibraryThumbnailLoader,
        isSkeleton: Bool
    ) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: ScreenbaseMetrics.collectionGridSpacing) {
                ForEach(items, id: \.self) { id in
                    if isSkeleton {
                        LibraryScreenshotTileView(
                            assetLocalIdentifier: id,
                            showsPlaceholder: true
                        )
                    } else if let record = metadataManager.screenshots.first(where: { $0.id == id }) {
                        LibraryScreenshotTileView(
                            assetLocalIdentifier: record.assetLocalIdentifier,
                            isSelected: viewModel.isSelected(record.id),
                            image: thumbnailLoader.image(for: record.assetLocalIdentifier)
                        ) {
                            viewModel.handleTileTap(screenshotId: record.id)
                        }
                        .onAppear {
                            thumbnailLoader.loadIfNeeded(assetLocalIdentifier: record.assetLocalIdentifier)
                        }
                    }
                }
            }
            .padding(.horizontal, ScreenbaseMetrics.edgePadding)
            .padding(.bottom, 88)
        }
    }

    private func emptyState(for filter: LibraryFilter) -> some View {
        VStack(spacing: 16) {
            Ph.images.bold
                .color(ScreenbaseColors.ink)
                .frame(width: ScreenbaseMetrics.emptyStateIconSize, height: ScreenbaseMetrics.emptyStateIconSize)

            Text(emptyCopy(for: filter))
                .font(.system(size: 16))
                .foregroundStyle(ScreenbaseColors.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func emptyCopy(for filter: LibraryFilter) -> String {
        switch filter {
        case .all:
            "Screenshots from Photos will show up here."
        case .collections:
            "No screenshots in collections yet."
        case .favorites:
            "No favorite screenshots yet."
        case .recent:
            "No screenshots from the last 7 days."
        }
    }

    private func placeholderIds(count: Int) -> [String] {
        (0..<count).map { "skeleton-\($0)" }
    }

    private func handleAddSource(_ source: LibraryAddSource) {
        switch source {
        case .camera, .gallery:
            break
        case .screenshotPicker:
            Task {
                await screenshotManager.runInitialScan()
            }
        }
    }
}

#Preview("Empty") {
    let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
    LibraryView()
        .environment(metadata)
        .environment(ScreenshotManager(service: MockScreenshotService(screenshots: []), index: metadata))
        .environment(PhotosManager(service: MockPhotosService(status: .authorized, screenshotCount: 0)))
}

#Preview("Populated") {
    let metadata = MetadataManager(local: InMemoryLocalMetadataStore(), remote: MockMetadataService())
    let screenshots = DiscoveredScreenshot.mocks
    LibraryView()
        .environment(metadata)
        .environment(ScreenshotManager(service: MockScreenshotService(screenshots: screenshots), index: metadata))
        .environment(PhotosManager(service: MockPhotosService(status: .authorized, screenshotCount: screenshots.count)))
        .task {
            try? await metadata.indexNewScreenshots(screenshots)
        }
}

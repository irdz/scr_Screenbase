//
//  CollectionNameSheet.swift
//  Screenbase
//

import SwiftUI

/// Bottom sheet for creating or renaming a collection / tag.
struct CollectionNameSheet: View {
    var title: String = "New Collection"
    var saveTitle: String = "Create"
    var placeholder: String = "Name"
    @Binding var name: String
    var canSave: Bool = false
    var onSave: () -> Void = {}
    var onCancel: () -> Void = {}

    @FocusState private var isNameFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: ScreenbaseMetrics.spacing * 2) {
                TextField(placeholder, text: $name)
                    .font(.system(size: 17))
                    .foregroundStyle(ScreenbaseColors.ink)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: ScreenbaseMetrics.radiusCard, style: .continuous)
                            .fill(ScreenbaseColors.lightGray)
                    )
                    .focused($isNameFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        guard canSave else { return }
                        onSave()
                    }

                VStack(spacing: 12) {
                    Button(saveTitle, action: onSave)
                        .buttonStyle(.screenbasePrimary)
                        .disabled(!canSave)

                    Button("Cancel", action: onCancel)
                        .buttonStyle(.screenbaseSecondary)
                }
                .padding(.top, ScreenbaseMetrics.spacing)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, ScreenbaseMetrics.edgePadding)
            .padding(.top, ScreenbaseMetrics.spacing)
            .padding(.bottom, ScreenbaseMetrics.edgePadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(ScreenbaseColors.elevated.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(ScreenbaseFonts.display(size: 17, weight: .bold))
                        .foregroundStyle(ScreenbaseColors.ink)
                }
            }
        }
        .presentationDetents([.height(280), .medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(ScreenbaseColors.elevated)
        .onAppear {
            isNameFocused = true
        }
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            CollectionNameSheet(
                title: "New Collection",
                saveTitle: "Create",
                name: .constant("Onboarding"),
                canSave: true
            )
        }
}

//
//  NumberedStepCardView.swift
//  Screenbase
//

import SwiftUI

struct NumberedStepCardView: View {
    var number: Int = 1
    var text: String = ""

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(number)")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(ScreenbaseColors.background)
                .frame(width: 32, height: 32)
                .background(Circle().fill(ScreenbaseColors.ink))

            Text(text)
                .font(.system(size: 16))
                .foregroundStyle(ScreenbaseColors.gray)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: ScreenbaseMetrics.radiusCard, style: .continuous)
                .fill(ScreenbaseColors.lightGray)
        )
    }
}

#Preview("Full") {
    NumberedStepCardView(number: 1, text: "Your screenshots stay on your device.")
        .padding()
}

#Preview("Empty") {
    NumberedStepCardView()
        .padding()
}

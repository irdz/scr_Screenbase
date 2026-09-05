//
//  HapticsManager.swift
//  Screenbase
//

import UIKit

/// Thin UIKit haptics helper. Not part of the Manager ← Service DI pattern.
final class HapticsManager {
    static let instance = HapticsManager()

    private init() {}

    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

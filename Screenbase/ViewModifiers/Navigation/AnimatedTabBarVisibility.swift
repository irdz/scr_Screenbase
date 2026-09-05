//
//  AnimatedTabBarVisibility.swift
//  Screenbase
//

import SwiftUI
import UIKit

extension View {
    /// Slides the system tab bar in from / out toward the bottom when `visibility` changes.
    func animatedTabBarVisibility(_ visibility: Visibility) -> some View {
        background {
            TabBarSlideEffect(isVisible: visibility == .visible)
                .frame(width: 0, height: 0)
                .accessibilityHidden(true)
        }
    }
}

enum TabBarVisibilityAnimation {
    static func set(_ visibility: Binding<Visibility>, to newValue: Visibility) {
        guard visibility.wrappedValue != newValue else { return }
        visibility.wrappedValue = newValue
    }
}

/// Drives a UIKit slide on the real `UITabBar` (SwiftUI toolbarVisibility only fades/snaps).
private struct TabBarSlideEffect: UIViewRepresentable {
    var isVisible: Bool

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.isHidden = true
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.animate(isVisible: isVisible, from: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        private var lastVisible: Bool?
        private let duration: TimeInterval = 0.32

        func animate(isVisible: Bool, from uiView: UIView) {
            guard lastVisible != isVisible else { return }

            // Wait a turn so we can resolve the tab bar from the hosted hierarchy.
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                guard let tabBar = Self.findTabBar(from: uiView) ?? Self.findTabBarInKeyWindow() else {
                    return
                }
                guard self.lastVisible != isVisible else { return }
                self.lastVisible = isVisible
                self.performSlide(on: tabBar, isVisible: isVisible)
            }
        }

        private func performSlide(on tabBar: UITabBar, isVisible: Bool, retryCount: Int = 0) {
            let height = max(tabBar.bounds.height, tabBar.frame.height)
            guard height > 0 else {
                guard retryCount < 3 else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.lastVisible = nil
                    self?.performSlide(on: tabBar, isVisible: isVisible, retryCount: retryCount + 1)
                }
                return
            }

            let hiddenTransform = CGAffineTransform(translationX: 0, y: height)
            tabBar.layer.removeAllAnimations()

            if isVisible {
                tabBar.isHidden = false
                if tabBar.transform == .identity {
                    tabBar.transform = hiddenTransform
                }
                UIView.animate(
                    withDuration: duration,
                    delay: 0,
                    options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]
                ) {
                    tabBar.transform = .identity
                }
            } else {
                UIView.animate(
                    withDuration: duration,
                    delay: 0,
                    options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction],
                    animations: {
                        tabBar.transform = hiddenTransform
                    },
                    completion: { finished in
                        guard finished else { return }
                        tabBar.isHidden = true
                        tabBar.transform = .identity
                    }
                )
            }
        }

        private static func findTabBar(from view: UIView) -> UITabBar? {
            var responder: UIResponder? = view
            while let current = responder {
                if let viewController = current as? UIViewController {
                    if let tabBar = viewController.tabBarController?.tabBar {
                        return tabBar
                    }
                    if let tabBar = viewController.findTabBarController()?.tabBar {
                        return tabBar
                    }
                }
                responder = current.next
            }
            return nil
        }

        private static func findTabBarInKeyWindow() -> UITabBar? {
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            let window = scenes
                .flatMap(\.windows)
                .first { $0.isKeyWindow }
                ?? scenes.flatMap(\.windows).first
            if let tabBar = window?.rootViewController?.findTabBarController()?.tabBar {
                return tabBar
            }
            guard let root = window else { return nil }
            return findTabBarView(in: root)
        }

        private static func findTabBarView(in view: UIView) -> UITabBar? {
            if let tabBar = view as? UITabBar {
                return tabBar
            }
            for subview in view.subviews {
                if let tabBar = findTabBarView(in: subview) {
                    return tabBar
                }
            }
            return nil
        }
    }
}

private extension UIViewController {
    func findTabBarController() -> UITabBarController? {
        if let tabBarController = self as? UITabBarController {
            return tabBarController
        }
        for child in children {
            if let found = child.findTabBarController() {
                return found
            }
        }
        return presentedViewController?.findTabBarController()
    }
}

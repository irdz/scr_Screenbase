//
//  Ph+EXT.swift
//  Screenbase
//

import PhosphorSwift
import SwiftUI
import UIKit

extension Ph {
    /// Phosphor SVGs are 256pt. Tab bars need a ~25pt template image.
    @MainActor
    var tabBarBold: Image {
        Image(uiImage: Self.tabBarTemplateImage(named: "\(rawValue)-bold"))
    }

    @MainActor
    private static func tabBarTemplateImage(named name: String, pointSize: CGFloat = 25) -> UIImage {
        if let cached = cache[name] {
            return cached
        }

        let size = CGSize(width: pointSize, height: pointSize)
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false

        let source = UIImage(named: name, in: phosphorBundle, compatibleWith: nil)
        let rendered = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            source?.draw(in: CGRect(origin: .zero, size: size))
        }
        let template = rendered.withRenderingMode(.alwaysTemplate)
        cache[name] = template
        return template
    }

    @MainActor
    private static var cache: [String: UIImage] = [:]

    private static var phosphorBundle: Bundle {
        let bundleName = "PhosphorSwift_PhosphorSwift.bundle"
        if let url = Bundle.main.resourceURL?.appendingPathComponent(bundleName),
           let bundle = Bundle(url: url)
        {
            return bundle
        }
        return Bundle.allBundles.first { bundle in
            UIImage(named: "squares-four-bold", in: bundle, compatibleWith: nil) != nil
        } ?? .main
    }
}

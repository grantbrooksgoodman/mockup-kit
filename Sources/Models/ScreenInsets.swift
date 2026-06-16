//
//  ScreenInsets.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import SwiftUI

/// The insets defining the screen region within a device frame image.
///
/// Values are specified in the frame image's native pixel coordinate space. They represent
/// the distance from each edge of the frame image to the corresponding edge of the screen
/// area.
public struct ScreenInsets: Sendable {
    // MARK: - Properties

    /// The distance from the bottom edge of the frame image to the bottom of the screen.
    public let bottom: CGFloat

    /// The corner radius of the screen region, in the frame image's native pixel space.
    ///
    /// The screenshot is clipped to a continuous rounded rectangle with this radius so that
    /// its corners align with the device bezel's screen opening. A value of `0` disables
    /// corner clipping.
    public let cornerRadius: CGFloat

    /// The distance from the left edge of the frame image to the left of the screen.
    public let left: CGFloat

    /// The distance from the right edge of the frame image to the right of the screen.
    public let right: CGFloat

    /// The distance from the top edge of the frame image to the top of the screen.
    public let top: CGFloat

    // MARK: - Init

    /// Creates screen insets with the specified edge distances and corner radius.
    ///
    /// Use this initializer when you know the exact screen region dimensions for a device
    /// frame. For automatic detection from a frame image, use ``detect(from:)`` instead.
    ///
    /// - Parameters:
    ///   - bottom: The distance from the bottom edge of the frame image to the screen.
    ///   - cornerRadius: The corner radius of the screen region, in the frame image's native pixel space.
    ///   - left: The distance from the left edge of the frame image to the screen.
    ///   - right: The distance from the right edge of the frame image to the screen.
    ///   - top: The distance from the top edge of the frame image to the screen.
    public init(
        bottom: CGFloat,
        cornerRadius: CGFloat,
        left: CGFloat,
        right: CGFloat,
        top: CGFloat
    ) {
        self.bottom = bottom
        self.cornerRadius = cornerRadius
        self.left = left
        self.right = right
        self.top = top
    }

    // MARK: - Methods

    /// Detects the screen region and corner radius from a device frame image's alpha channel.
    ///
    /// The method scans inward from each image edge to locate the first
    /// bezel-to-transparent transition, which marks the screen boundary. This approach
    /// correctly handles internal opaque elements such as a Dynamic Island or notch.
    ///
    /// - Parameter cgImage: The device frame image. The screen area must be fully transparent.
    ///
    /// - Returns: Insets describing the screen region within the image.
    public static func detect(
        from cgImage: CGImage
    ) throws -> ScreenInsets {
        let height = cgImage.height
        let width = cgImage.width

        guard let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data,
              let pointer = CFDataGetBytePtr(data) else {
            throw MockupKit.Error.screenDetectionFailed
        }

        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let bytesPerRow = cgImage.bytesPerRow

        guard bytesPerPixel >= 2 else {
            throw MockupKit.Error.screenDetectionFailed
        }

        // Determine alpha byte offset by probing the center pixel,
        // which must be transparent (screen area).
        let centerX = width / 2
        let centerY = height / 2
        let centerOffset = centerY * bytesPerRow + centerX * bytesPerPixel

        let alphaOffset: Int
        if pointer[centerOffset + bytesPerPixel - 1] == 0 {
            alphaOffset = bytesPerPixel - 1
        } else if pointer[centerOffset] == 0 {
            alphaOffset = 0
        } else {
            throw MockupKit.Error.screenDetectionFailed
        }

        func isOpaque(
            x: Int,
            y: Int
        ) -> Bool {
            pointer[y * bytesPerRow + x * bytesPerPixel + alphaOffset] > 0
        }

        // Scan from top edge inward: outside/transparent → bezel/opaque → screen/transparent
        var topInset = 0
        var foundBezel = false
        for y in 0 ..< height {
            if isOpaque(
                x: centerX,
                y: y
            ) {
                foundBezel = true
            } else if foundBezel {
                topInset = y
                break
            }
        }

        // Scan from bottom edge inward
        var bottomInset = 0
        foundBezel = false
        for y in stride(
            from: height - 1,
            through: 0,
            by: -1
        ) {
            if isOpaque(
                x: centerX,
                y: y
            ) {
                foundBezel = true
            } else if foundBezel {
                bottomInset = height - 1 - y
                break
            }
        }

        // Scan from left edge inward
        var leftInset = 0
        foundBezel = false
        for x in 0 ..< width {
            if isOpaque(
                x: x,
                y: centerY
            ) {
                foundBezel = true
            } else if foundBezel {
                leftInset = x
                break
            }
        }

        // Scan from right edge inward
        var rightInset = 0
        foundBezel = false
        for x in stride(
            from: width - 1,
            through: 0,
            by: -1
        ) {
            if isOpaque(
                x: x,
                y: centerY
            ) {
                foundBezel = true
            } else if foundBezel {
                rightInset = width - 1 - x
                break
            }
        }

        // Detect corner radius using two complementary scans and their
        // geometric mean, which closely approximates the visual corner
        // radius of the screen opening.
        //
        // Scan 1 (vertical): distance from (leftInset, topInset) downward
        // to the first bezel pixel – measures the outer gap.
        var outerGap: CGFloat = 0
        for y in topInset ..< height {
            if isOpaque(
                x: leftInset,
                y: y
            ) {
                outerGap = CGFloat(y - topInset)
                break
            }
        }

        // Scan 2 (horizontal): distance from leftInset rightward along
        // y = topInset to the first screen-opening pixel (the bezel-to-
        // transparent transition) – measures the full corner extent.
        var cornerExtent: CGFloat = 0
        var foundBezelAtCorner = false
        for x in leftInset ..< width {
            if isOpaque(
                x: x,
                y: topInset
            ) {
                foundBezelAtCorner = true
            } else if foundBezelAtCorner {
                cornerExtent = CGFloat(x - leftInset)
                break
            }
        }

        let cornerRadius = (outerGap > 0 && cornerExtent > 0)
            ? sqrt(outerGap * cornerExtent)
            : max(outerGap, cornerExtent)

        return ScreenInsets(
            bottom: CGFloat(bottomInset),
            cornerRadius: cornerRadius,
            left: CGFloat(leftInset),
            right: CGFloat(rightInset),
            top: CGFloat(topInset)
        )
    }
}

//
//  DeviceFrame.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import SwiftUI

/// The configuration for a device frame displayed on the mockup canvas.
///
/// The frame is rendered from a bezel image file, typically sourced from
/// [frameit-frames](https://github.com/fastlane/frameit-frames). The ``scale`` property
/// determines the frame's width relative to the canvas, and ``screenInsets`` defines
/// where the app screenshot is composited within the bezel.
public struct DeviceFrame: Sendable {
    // MARK: - Properties

    /// The file URL of the device frame PNG image.
    ///
    /// The image should contain the device bezel with a transparent center where the
    /// app screenshot is placed.
    public let imageFile: URL

    /// The positional offset from the canvas center, in points.
    ///
    /// A positive `x` value shifts the frame rightward; a positive `y` value shifts
    /// it downward. Use this to position the device off-center or partially off-canvas
    /// for cropped compositions.
    public let offset: CGPoint

    /// The frame width as a fraction of the canvas width.
    ///
    /// A value of `0.75` renders the frame at 75% of the canvas width. The height
    /// is calculated automatically to preserve the image's aspect ratio.
    public let scale: CGFloat

    /// The insets that define the screen region within the frame image.
    ///
    /// Values are specified in the frame image's native pixel coordinate space and
    /// are scaled proportionally when the frame is resized on the canvas.
    public let screenInsets: ScreenInsets

    /// An optional shadow rendered behind the device frame.
    public let shadow: MockupShadow?

    // MARK: - Init

    /// Creates a device frame with automatically detected screen insets.
    ///
    /// The initializer loads the image at `imageFile` and scans its alpha channel to
    /// determine where the transparent screen region begins, eliminating the need to
    /// specify ``ScreenInsets`` manually.
    ///
    /// - Parameters:
    ///   - imageFile: The file URL of the device frame PNG.
    ///   - offset: The positional offset from the canvas center.
    ///   - scale: The frame width as a fraction of the canvas width.
    ///   - shadow: An optional shadow rendered behind the frame.
    public init(
        imageFile: URL,
        offset: CGPoint = .zero,
        scale: CGFloat = 0.75,
        shadow: MockupShadow? = .default
    ) throws {
        guard let image = UIImage(contentsOfFile: imageFile.path),
              let cgImage = image.cgImage else {
            throw MockupKit.Error.imageLoadFailed(imageFile)
        }

        self.init(
            imageFile: imageFile,
            offset: offset,
            scale: scale,
            screenInsets: try .detect(from: cgImage),
            shadow: shadow
        )
    }

    /// Creates a device frame with the specified screen insets.
    ///
    /// Use this initializer when you have predetermined screen region values and do not
    /// need automatic detection from the frame image.
    ///
    /// - Parameters:
    ///   - imageFile: The file URL of the device frame PNG.
    ///   - offset: The positional offset from the canvas center.
    ///   - scale: The frame width as a fraction of the canvas width.
    ///   - screenInsets: The insets that define the screen region within the frame image.
    ///   - shadow: An optional shadow rendered behind the frame.
    public init(
        imageFile: URL,
        offset: CGPoint = .zero,
        scale: CGFloat = 0.75,
        screenInsets: ScreenInsets,
        shadow: MockupShadow? = .default
    ) {
        self.imageFile = imageFile
        self.offset = offset
        self.scale = scale
        self.screenInsets = screenInsets
        self.shadow = shadow
    }
}

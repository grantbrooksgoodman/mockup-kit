//
//  OutputSize.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import SwiftUI

/// The output dimensions for a generated mockup PNG.
///
/// Use ``large`` and ``small`` for the standard App Store display
/// classes, ``playStore(_:)`` for Google Play, and
/// ``custom(width:height:)`` for arbitrary dimensions.
///
/// - Note: Google Play sizes are rendered without an alpha channel.
///   All other sizes include one.
public enum OutputSize: Hashable, Sendable {
    // MARK: - Cases

    /// Custom output dimensions specified in pixels.
    case custom(
        width: CGFloat,
        height: CGFloat
    )

    /// The 6.9-inch display class (1290 x 2796).
    case large

    /// A Google Play display class.
    ///
    /// The image is rendered without an alpha channel.
    case playStore(PlayStoreSize)

    /// The 5.5-inch display class (1242 x 2208).
    case small

    // MARK: - Properties

    /// The canvas dimensions in pixels.
    public var dimensions: CGSize {
        switch self {
        case let .custom(width, height):
            CGSize(
                width: width,
                height: height
            )

        case .large:
            OutputSize.largeDimensions

        case let .playStore(size):
            size.dimensions

        case .small:
            OutputSize.smallDimensions
        }
    }

    /// The directory name used when writing mockups to disk.
    var directoryName: String {
        switch self {
        case let .custom(width, height):
            "\(Int(width))x\(Int(height))"

        case .large:
            "app-store/large"

        case let .playStore(size):
            "play-store/\(size.directoryName)"

        case .small:
            "app-store/small"
        }
    }

    var isOpaque: Bool {
        if case .playStore = self { return true }
        return false
    }
}

public extension OutputSize {
    /// The output dimensions for a Google Play mockup.
    ///
    /// Use ``phone`` for phone screenshots, or
    /// ``custom(width:height:)`` for any other dimensions.
    enum PlayStoreSize: Hashable, Sendable {
        // MARK: - Cases

        /// Custom output dimensions specified in pixels.
        case custom(
            width: CGFloat,
            height: CGFloat
        )

        /// The phone display class (1080 x 1920).
        case phone

        // MARK: - Properties

        var dimensions: CGSize {
            switch self {
            case let .custom(width, height):
                CGSize(
                    width: width,
                    height: height
                )

            case .phone:
                OutputSize.playStorePhoneDimensions
            }
        }

        var directoryName: String {
            switch self {
            case let .custom(width, height):
                "\(Int(width))x\(Int(height))"

            case .phone:
                "phone"
            }
        }
    }
}

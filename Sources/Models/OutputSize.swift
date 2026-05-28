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
public enum OutputSize: Hashable, Sendable {
    /// Custom output dimensions specified in pixels.
    case custom(
        width: CGFloat,
        height: CGFloat
    )
    
    /// The 6.9-inch display class (1290 x 2796).
    case large

    /// The 5.5-inch display class (1242 x 2208).
    case small

    // MARK: - Computed Properties

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
            "large"

        case .small:
            "small"
        }
    }
}

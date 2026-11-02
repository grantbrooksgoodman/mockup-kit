//
//  Background.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import SwiftUI

/// The background fill for a mockup canvas.
///
/// - Important: Use an opaque background for Google Play sizes. The
///   image is rendered without an alpha channel.
public enum Background: Sendable {
    /// A solid color fill.
    case color(Color)

    /// An image that fills the canvas.
    case image(URL)

    /// A linear gradient between two or more colors.
    case linearGradient(
        colors: [Color],
        startPoint: UnitPoint,
        endPoint: UnitPoint
    )
}

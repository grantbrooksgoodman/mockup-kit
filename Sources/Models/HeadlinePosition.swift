//
//  HeadlinePosition.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import SwiftUI

/// The position of a headline on the mockup canvas.
///
/// Grouped positions like ``above(spacing:)`` and ``below(spacing:)`` move with the device
/// frame's ``DeviceFrame/offset``, while canvas-anchored positions like ``canvasTop(padding:)``
/// and ``canvasBottom(padding:)`` remain fixed relative to the canvas edges.
public enum HeadlinePosition: Sendable {
    /// Positioned above the device frame with the specified spacing.
    ///
    /// The headline and device frame are laid out as a vertical group, with the
    /// headline on top. The frame's ``DeviceFrame/offset`` applies to the entire group.
    case above(spacing: CGFloat = 40)

    /// Positioned below the device frame with the specified spacing.
    ///
    /// The headline and device frame are laid out as a vertical group, with the
    /// headline on the bottom. The frame's ``DeviceFrame/offset`` applies to the entire group.
    case below(spacing: CGFloat = 40)

    /// Anchored to the bottom edge of the canvas with the specified padding.
    ///
    /// The headline is positioned independently from the device frame. Use this when
    /// the device needs to be offset separately from the headline.
    case canvasBottom(padding: CGFloat = 80)

    /// Anchored to the top edge of the canvas with the specified padding.
    ///
    /// The headline is positioned independently from the device frame. Use this when
    /// the device needs to be offset separately from the headline.
    case canvasTop(padding: CGFloat = 80)

    /// Positioned at an absolute point on the canvas.
    case custom(x: CGFloat, y: CGFloat)

    /// Vertically centered between the bottom edge of the device frame and the
    /// bottom edge of the canvas.
    ///
    /// Use `offset` to nudge the headline from the calculated midpoint. Positive
    /// values move it downward.
    case equidistantBottom(offset: CGFloat = 0)

    /// Vertically centered between the top edge of the canvas and the top edge
    /// of the device frame.
    ///
    /// Use `offset` to nudge the headline from the calculated midpoint. Positive
    /// values move it downward.
    case equidistantTop(offset: CGFloat = 0)
}

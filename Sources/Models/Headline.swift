//
//  Headline.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import SwiftUI

/* Proprietary */
import ComponentKit

/// The headline text overlaid on the mockup canvas.
///
/// Headlines are rendered using ComponentKit's text system, providing consistent
/// typography across your app and its marketing materials.
public struct Headline: Sendable {
    // MARK: - Properties

    /// The horizontal alignment of multiline text.
    public let alignment: TextAlignment

    /// The font used to render the headline.
    public let font: ComponentKit.Font

    /// The color of the headline text.
    public let foregroundColor: Color

    /// The maximum width of the headline text block, in points.
    ///
    /// When `nil`, the headline uses 85% of the canvas width.
    public let maximumWidth: CGFloat?

    /// The position of the headline relative to the device frame or canvas.
    public let position: HeadlinePosition

    /// An optional subtitle displayed beneath the headline text.
    public let subtitle: Subtitle?

    /// The text content of the headline.
    ///
    /// Use `\n` for explicit line breaks. Text wraps automatically when it
    /// exceeds ``maximumWidth``.
    public let text: String

    // MARK: - Init

    /// Creates a headline with the specified text, font, and positioning.
    ///
    /// - Parameters:
    ///   - text: The text content of the headline. Use `\n` for explicit line breaks.
    ///   - alignment: The horizontal alignment of multiline text.
    ///   - font: The font used to render the headline.
    ///   - foregroundColor: The color of the headline text.
    ///   - maximumWidth: The maximum width of the text block in points, or `nil` to use
    ///     a default width.
    ///   - position: The position relative to the device frame or canvas.
    ///   - subtitle: An optional subtitle displayed beneath the headline.
    public init(
        _ text: String,
        alignment: TextAlignment = .center,
        font: ComponentKit.Font,
        foregroundColor: Color,
        maximumWidth: CGFloat? = nil,
        position: HeadlinePosition = .above(),
        subtitle: Subtitle? = nil
    ) {
        self.alignment = alignment
        self.font = font
        self.foregroundColor = foregroundColor
        self.maximumWidth = maximumWidth
        self.position = position
        self.subtitle = subtitle
        self.text = text
    }
}

// MARK: - Headline.Subtitle

public extension Headline {
    /// Secondary text displayed beneath the headline.
    struct Subtitle: Sendable {
        // MARK: - Properties

        /// The font used to render the subtitle.
        public let font: ComponentKit.Font

        /// The color of the subtitle text.
        public let foregroundColor: Color

        /// The vertical spacing between the headline and subtitle, in points.
        public let spacing: CGFloat

        /// The text content of the subtitle.
        public let text: String

        // MARK: - Init

        /// Creates a subtitle with the specified text, font, and color.
        ///
        /// - Parameters:
        ///   - text: The text content of the subtitle.
        ///   - font: The font used to render the subtitle.
        ///   - foregroundColor: The color of the subtitle text.
        ///   - spacing: The vertical spacing between the headline and subtitle, in points.
        public init(
            _ text: String,
            font: ComponentKit.Font,
            foregroundColor: Color,
            spacing: CGFloat = 20
        ) {
            self.font = font
            self.foregroundColor = foregroundColor
            self.spacing = spacing
            self.text = text
        }
    }
}
